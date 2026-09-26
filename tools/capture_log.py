"""Archive a console snapshot without modifying the live game log."""
import argparse
from datetime import datetime, timezone
from pathlib import Path
import shutil

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--source", type=Path, default=Path.home() / "Zomboid/console.txt")
parser.add_argument("--output-dir", type=Path, default=Path(__file__).resolve().parents[1] / "work/test-logs")
args = parser.parse_args()
args.output_dir.mkdir(parents=True, exist_ok=True)
target = args.output_dir / (datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ") + "-console.txt")
shutil.copy2(args.source, target)
lines = target.read_text(encoding="utf-8", errors="replace").splitlines()
interesting = [line for line in lines if any(key in line for key in ("ProjectTerm", "PROJECT TERM", "ERROR", "SEVERE", "version="))]
target.with_suffix(".summary.txt").write_text("\n".join(interesting) + "\n", encoding="utf-8")
print(f"Captured {target}; {len(interesting)} diagnostic lines (review attribution manually).")
