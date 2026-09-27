"""Lossless static Meshy GLB inspection/export for the supplied weapon assets.

No decimation, face filtering, UV regeneration, welding or texture resizing.
Refuses unsupported GLBs instead of silently dropping their contents.
"""
import argparse
from collections import Counter
import hashlib
import io
import json
import math
from pathlib import Path
import re
import struct


def load_glb(path):
    raw = Path(path).read_bytes()
    magic, version, length = struct.unpack_from('<4sII', raw)
    if (magic, version, length) != (b'glTF', 2, len(raw)):
        raise ValueError('Expected complete glTF 2 binary')
    chunks, offset = {}, 12
    while offset < len(raw):
        size, kind = struct.unpack_from('<II', raw, offset)
        chunks[kind] = raw[offset + 8:offset + 8 + size]
        offset += size + 8
    doc, binary = json.loads(chunks[0x4e4f534a]), chunks[0x004e4942]
    if len(doc['meshes']) != 1 or len(doc['meshes'][0]['primitives']) != 1 or doc.get('skins') or doc.get('animations'):
        raise ValueError('Only one static primitive is supported; refusing partial export')
    identity = [1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1]
    if len(doc['nodes']) != 1 or doc['nodes'][0].get('matrix', identity) != identity:
        raise ValueError('Nonidentity node hierarchy requires explicit conversion')
    if any(k in doc['nodes'][0] for k in ('rotation','translation','scale')):
        raise ValueError('TRS transforms not supported')
    primitive = doc['meshes'][0]['primitives'][0]
    if primitive.get('mode', 4) != 4 or primitive.get('extensions'):
        raise ValueError('Expected ordinary indexed triangles')
    def read(index):
        a = doc['accessors'][index]
        if a.get('sparse') or a.get('normalized'):
            raise ValueError('Sparse/normalized accessors unsupported')
        view = doc['bufferViews'][a['bufferView']]
        count = {'SCALAR':1,'VEC2':2,'VEC3':3}[a['type']]
        fmt = '<' + {5126:'f',5125:'I',5123:'H',5121:'B'}[a['componentType']] * count
        stride = view.get('byteStride', struct.calcsize(fmt))
        start = view.get('byteOffset',0) + a.get('byteOffset',0)
        return [struct.unpack_from(fmt, binary, start + i*stride) for i in range(a['count'])]
    position = read(primitive['attributes']['POSITION'])
    normal = read(primitive['attributes']['NORMAL'])
    uv = read(primitive['attributes']['TEXCOORD_0'])
    indices = [a[0] for a in read(primitive['indices'])]
    if len(indices)%3 or len(position)!=len(uv) or len(position)!=len(normal) or max(indices)>=len(position):
        raise ValueError('Invalid mesh arrays')
    faces = [tuple(indices[i:i+3]) for i in range(0,len(indices),3)]
    material = doc['materials'][primitive['material']]
    texture = material['pbrMetallicRoughness']['baseColorTexture']
    if texture.get('texCoord',0)!=0 or texture.get('extensions'):
        raise ValueError('Unsupported base-color UV transform')
    img = doc['images'][doc['textures'][texture['index']]['source']]
    if img.get('mimeType') not in ('image/png','image/jpeg'):
        raise ValueError('Unsupported embedded image format')
    view = doc['bufferViews'][img['bufferView']]
    png = binary[view.get('byteOffset',0):view.get('byteOffset',0)+view['byteLength']]
    return position, faces, normal, uv, png, hashlib.sha256(raw).hexdigest()


def load_x(path):
    text = Path(path).read_text(encoding='utf-8')
    match = re.search(r'(?m)^\s*Mesh\s+[^\s{]*\s*\{\s*(\d+);',text)
    def vectors(start, count, dims):
        pat = r';'.join([r'([-+\d.eE]+)']*dims) + r';[,;]'
        values=[]
        for m in re.finditer(pat,text[start:]):
            values.append(tuple(map(float,m.groups())))
            if len(values)==count: return values,start+m.end()
        raise ValueError('Incomplete X vectors')
    p,end=vectors(match.end(),int(match[1]),3)
    m=re.match(r'\s*(\d+);',text[end:]); end+=m.end(); count=int(m[1])
    faces=[tuple(map(int,m.groups())) for m in list(re.finditer(r'3;(\d+),(\d+),(\d+);[,;]',text[end:]))[:count]]
    m=re.search(r'MeshNormals\s*\{\s*(\d+);',text)
    normals,_=vectors(m.end(),int(m[1]),3)
    m=re.search(r'MeshTextureCoords\s*(?:\w+\s*)?\{\s*(\d+);',text)
    uv,_=vectors(m.end(),int(m[1]),2)
    return p,faces,normals,uv


def topology(position, faces):
    # Weld only for measurement, not export: UV seams share physical edges.
    ids, keys = {}, []
    for p in position:
        key=tuple(round(v,5) for v in p)
        if key not in ids: ids[key]=len(ids)
        keys.append(ids[key])
    edges=Counter()
    for a,b,c in faces:
        for u,v in ((a,b),(b,c),(c,a)):
            edges[tuple(sorted((keys[u],keys[v])))] += 1
    return {'vertices':len(position),'triangles':len(faces),
            'boundary_edges':sum(v==1 for v in edges.values()),
            'nonmanifold_edges':sum(v>2 for v in edges.values()),
            'bounds':[[min(p[i] for p in position),max(p[i] for p in position)] for i in range(3)]}


def export(source, output, asset, length, grip=(-.08,-.12,0)):
    p,f,n,uv,png,digest=load_glb(source)
    if not png.startswith(b'\x89PNG'):
        from PIL import Image
        buffer=io.BytesIO()
        Image.open(io.BytesIO(png)).save(buffer,format='PNG')
        png=buffer.getvalue()
    scale=length/(max(v[0] for v in p)-min(v[0] for v in p))
    # Source weapon barrel faces -X, Y up. Match vanilla M16 .x axes:
    # X thickness, +Y toward muzzle, Z up. Grip pivot is a tuning candidate.
    # Preserve all original topology and invert winding for the reflection.
    gx,gy,gz=grip
    outp=[((z-gz)*scale, -(x-gx)*scale, (y-gy)*scale) for x,y,z in p]
    outn=[(z,-x,y) for x,y,z in n]
    outf=[(a,c,b) for a,b,c in f]
    def vecs(values):
        return '\n'.join(';'.join(format(x,'.9g') for x in row)+';'+(';' if i==len(values)-1 else ',') for i,row in enumerate(values))
    def tris(values):
        return '\n'.join('3;'+','.join(map(str,row))+';'+(';' if i==len(values)-1 else ',') for i,row in enumerate(values))
    model=output/'models_X/Terminator'/f'{asset}.x'
    texture=output/'textures/Terminator'/f'{asset}.png'
    model.parent.mkdir(parents=True,exist_ok=True);texture.parent.mkdir(parents=True,exist_ok=True)
    text=f'''xof 0303txt 0032
Mesh {asset} {{
{len(outp)};
{vecs(outp)}
{len(outf)};
{tris(outf)}
MeshNormals {{
{len(outn)};
{vecs(outn)}
{len(outf)};
{tris(outf)}
}}
MeshTextureCoords {{
{len(uv)};
{vecs(uv)}
}}
MeshMaterialList {{
1;
{len(outf)};
{','.join(['0']*len(outf))};
Material material0 {{
1.0;1.0;1.0;1.0;;
16.0;
0.0;0.0;0.0;;
0.0;0.0;0.0;;
TextureFilename {{ "{asset}.png"; }}
}}
}}
}}
'''
    model.write_text(text,encoding='utf-8');texture.write_bytes(png)
    check=load_x(model)
    assert check[1]==outf and len(check[0])==len(p) and len(check[3])==len(uv)
    result={'source':Path(source).name,'source_sha256':digest,'asset':asset,'scale':scale,'grip_source':list(grip),
            'source_topology':topology(p,f),'export_topology':topology(outp,outf),
            'triangles_removed':0,'vertices_removed':0,'texture_sha256':hashlib.sha256(png).hexdigest()}
    (output/f'{asset}.manifest.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    return result


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source',type=Path);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--asset',required=True);parser.add_argument('--length',type=float,default=.55)
    parser.add_argument('--grip',nargs=3,type=float,default=[-.08,-.12,0],help='Source-space grip pivot; provisional until in-game alignment')
    args=parser.parse_args()
    if not re.fullmatch('[a-z0-9_]+',args.asset) or not 0<args.length<2: parser.error('Invalid asset name or length')
    print(json.dumps(export(args.source,args.output,args.asset,args.length,args.grip),indent=2))
