"""Build an install-only ZIP; refuse missing meshes/textures. Python 3.10+."""
import argparse
import hashlib
import json
from pathlib import Path
import re
from zipfile import ZipFile, ZIP_DEFLATED

ROOT = Path(__file__).resolve().parents[1]


def collect(asset_dir):
    files = {}
    for folder in ("42", "common"):
        for path in (ROOT / folder).rglob("*"):
            if path.is_file():
                files[path.relative_to(ROOT).as_posix()] = path
    for folder in ("models_X", "textures"):
        for path in (asset_dir / folder).rglob("*"):
            if path.is_file():
                name = "42/media/" + path.relative_to(asset_dir).as_posix()
                if name in files:
                    raise ValueError(f"Asset overlay conflicts with tracked file: {name}")
                files[name] = path
    return files


def validate(files):
    errors = []
    for required in ("42/mod.info", "common/.gitkeep", "42/media/registries.lua",
                     "42/media/sandbox-options.txt"):
        if required not in files:
            errors.append(f"Missing required file: {required}")
    for name, path in files.items():
        if path.suffix == ".json":
            try:
                json.loads(path.read_text(encoding="utf-8-sig"))
            except ValueError as error:
                errors.append(f"{name}: {error}")
        if name.startswith("42/media/scripts/"):
            text = path.read_text(encoding="utf-8-sig")
            for kind, value in re.findall(r"\b(mesh|texture)\s*=\s*([^,\s]+)", text):
                if kind == "mesh":
                    candidates = [f"42/media/models_X/{value}.{ext}" for ext in ("x", "fbx")]
                else:
                    candidates = [f"42/media/textures/{value}.png"]
                if not any(candidate in files for candidate in candidates):
                    errors.append(f"{name}: missing {kind} {value}")
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--assets", type=Path, default=ROOT / "assets/prepared")
    parser.add_argument("--output", type=Path, default=ROOT / "dist/ProjectTermModPack-0.2.0.zip")
    args = parser.parse_args()
    files = collect(args.assets)
    errors = validate(files)
    if errors:
        raise SystemExit("\n".join(errors))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    manifest = {}
    with ZipFile(args.output, "w", ZIP_DEFLATED) as archive:
        for name, path in sorted(files.items()):
            data = path.read_bytes()
            archive.writestr("project-term-mod-pack/" + name, data)
            manifest[name] = {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}
    with ZipFile(args.output) as archive:
        if archive.testzip():
            raise SystemExit("ZIP integrity failed")
    args.output.with_suffix(".manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Packaged {len(files)} files: {args.output} (gameplay not validated)")


if __name__ == "__main__":
    main()
