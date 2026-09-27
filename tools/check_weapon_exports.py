"""Verify repaired exports preserve source topology, UVs, normals and texture pixels."""
import argparse
import io
import json
from pathlib import Path
from PIL import Image
from weapon_mesh import load_glb, load_x, topology

parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--source-dir',required=True,type=Path)
parser.add_argument('--assets',type=Path,default=Path('assets/prepared'))
parser.add_argument('--manifest',type=Path,default=Path('docs/weapon-export-manifests.json'))
args=parser.parse_args()
for record in json.loads(args.manifest.read_text()):
    name=record['asset']
    p,f,n,uv,texture,digest=load_glb(args.source_dir/record['source'])
    ep,ef,en,eu=load_x(args.assets/f'models_X/Terminator/{name}.x')
    assert digest==record['source_sha256'],name+' source hash'
    assert len(ep)==len(p) and ef==[(a,c,b) for a,b,c in f],name+' full topology'
    scale=record['scale']; gx,gy,gz=record['grip_source']
    for source,exported in zip(p,ep):
        x,y,z=source
        assert max(abs(a-b) for a,b in zip(((z-gz)*scale,-(x-gx)*scale,(y-gy)*scale),exported))<1e-7
    for source,exported in zip(n,en):
        x,y,z=source
        assert max(abs(a-b) for a,b in zip((z,-x,y),exported))<1e-7
    assert max(abs(a-b) for source,exported in zip(uv,eu) for a,b in zip(source,exported))<1e-7
    source_image=Image.open(io.BytesIO(texture)).convert('RGB')
    exported_image=Image.open(args.assets/f'textures/Terminator/{name}.png').convert('RGB')
    assert source_image.size==exported_image.size and source_image.tobytes()==exported_image.tobytes(),name+' texture pixels'
    stats=topology(ep,ef)
    assert stats['boundary_edges']==0 and stats['nonmanifold_edges']==0,name+' closed mesh'
    print(f'PASS {name}: {len(ep)} vertices, {len(ef)} triangles, no removed faces, unchanged UVs/texture pixels')
