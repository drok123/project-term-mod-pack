# Run in Blender 4.x:
# blender --background --python tools/blender_export_fbx.py -- <prepared-package-root>
import bpy, sys
from pathlib import Path

root = Path(sys.argv[-1]).resolve()
staging = root / "staging_obj"
out = root / "42/media/models_X/Terminator_fbx"
out.mkdir(parents=True, exist_ok=True)

for obj in sorted(staging.glob("*.obj")):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    if hasattr(bpy.ops.wm, "obj_import"):
        bpy.ops.wm.obj_import(filepath=str(obj))
    else:
        bpy.ops.import_scene.obj(filepath=str(obj))

    for o in bpy.context.scene.objects:
        if o.type == "MESH":
            bpy.context.view_layer.objects.active = o
            o.select_set(True)
            bpy.ops.object.shade_smooth()
            bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

    bpy.ops.export_scene.fbx(
        filepath=str(out / (obj.stem + ".fbx")),
        use_selection=False,
        add_leaf_bones=False,
        bake_anim=False,
        axis_forward="-Y",
        axis_up="Z",
    )

print("FBX export complete:", out)
