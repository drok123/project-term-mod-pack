"""Diagnostic orthographic software render; needs numpy and Pillow, no game claim."""
import argparse
import io
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw
from weapon_mesh import load_glb, load_x


def render(p, f, n, uv, image, width=1400, height=430):
    p, f, n, uv = map(np.asarray, (p, f, n, uv))
    # Small view angle reveals the barrel and the thickness.
    angle=.20
    rotation=np.array([[np.cos(angle),0,np.sin(angle)],[0,1,0],[-np.sin(angle),0,np.cos(angle)]])
    p=p@rotation.T; n=n@rotation.T
    bounds=np.array([p.min(axis=0),p.max(axis=0)])
    scale=min((width-80)/(bounds[1,0]-bounds[0,0]),(height-50)/(bounds[1,1]-bounds[0,1]))
    screen=p.copy();screen[:,0]=(p[:,0]-bounds[:,0].mean())*scale+width/2
    screen[:,1]=height/2-(p[:,1]-bounds[:,1].mean())*scale
    frame=np.full((height,width,3),[35,43,53],dtype=np.uint8)
    depth=np.full((height,width),-np.inf)
    tex=np.asarray(image.convert('RGB'))
    for face in f:
        a,b,c=screen[face]
        lo=np.maximum(np.floor(np.minimum(np.minimum(a[:2],b[:2]),c[:2])).astype(int),0)
        hi=np.minimum(np.ceil(np.maximum(np.maximum(a[:2],b[:2]),c[:2])).astype(int),[width-1,height-1])
        if np.any(hi<lo): continue
        den=(b[1]-c[1])*(a[0]-c[0])+(c[0]-b[0])*(a[1]-c[1])
        if abs(den)<1e-8: continue
        yy,xx=np.mgrid[lo[1]:hi[1]+1,lo[0]:hi[0]+1];xx=xx+.5;yy=yy+.5
        w0=((b[1]-c[1])*(xx-c[0])+(c[0]-b[0])*(yy-c[1]))/den
        w1=((c[1]-a[1])*(xx-c[0])+(a[0]-c[0])*(yy-c[1]))/den
        w2=1-w0-w1
        z=w0*a[2]+w1*b[2]+w2*c[2]
        dest=depth[lo[1]:hi[1]+1,lo[0]:hi[0]+1]
        mask=(w0>=0)&(w1>=0)&(w2>=0)&(z>dest)
        if not mask.any(): continue
        weights=np.stack([w0[mask],w1[mask],w2[mask]],axis=1)
        coords=weights@uv[face]
        tx=np.clip((coords[:,0]*(tex.shape[1]-1)).astype(int),0,tex.shape[1]-1)
        ty=np.clip((coords[:,1]*(tex.shape[0]-1)).astype(int),0,tex.shape[0]-1)
        norms=weights@n[face]
        brightness=.50+.50*np.maximum(0,norms@np.array([-.25,.45,.86]))
        patch=frame[lo[1]:hi[1]+1,lo[0]:hi[0]+1]
        patch[mask]=np.clip(tex[ty,tx]*brightness[:,None],0,255).astype(np.uint8)
        dest[mask]=z[mask]
    return Image.fromarray(frame)


if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('source');ap.add_argument('--old');ap.add_argument('--old-texture');ap.add_argument('--rebuilt');ap.add_argument('--rebuilt-texture');ap.add_argument('--output',required=True)
    args=ap.parse_args()
    p,f,n,uv,texture,_=load_glb(args.source)
    new=render(p,f,n,uv,Image.open(io.BytesIO(texture)))
    rows=[]
    if args.old:
        op,of,on,ou=load_x(args.old)
        # Prior export stores Y-up source as Z-up X coordinates.
        op=[(x,z,-y) for x,y,z in op];on=[(x,z,-y) for x,y,z in on]
        old=render(op,of,on,ou,Image.open(args.old_texture))
        rows.append(('OLD EXPORT | '+str(len(of))+' triangles; open mesh boundaries',old))
    if args.rebuilt:
        ep,ef,en,eu=load_x(args.rebuilt)
        ep=[(-y,z,x) for x,y,z in ep];en=[(-y,z,x) for x,y,z in en]
        new=render(ep,ef,en,eu,Image.open(args.rebuilt_texture))
    rows.append((('REBUILT EXPORT' if args.rebuilt else 'NEW SOURCE')+' | '+str(len(f))+' triangles; all faces retained',new))
    canvas=Image.new('RGB',(1400,len(rows)*480),(22,28,36));draw=ImageDraw.Draw(canvas)
    for i,(label,img) in enumerate(rows):
        draw.text((24,i*480+15),label,fill=(235,239,246));canvas.paste(img,(0,i*480+45))
    out=Path(args.output);out.parent.mkdir(parents=True,exist_ok=True);canvas.save(out)
