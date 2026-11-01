#!/usr/bin/env python3
"""Create an installable shader-pack ZIP with shaders/ at archive root."""
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "dist" / "HYPERREAL-SHADERS.zip"
SHADERS = ROOT / "shaders"
if not SHADERS.is_dir():
    raise SystemExit("Missing shaders/ directory")
OUT.parent.mkdir(parents=True, exist_ok=True)
with ZipFile(OUT, "w", ZIP_DEFLATED, compresslevel=9) as archive:
    for path in sorted(SHADERS.rglob("*")):
        if path.is_file():
            archive.write(path, path.relative_to(ROOT).as_posix())
with ZipFile(OUT) as archive:
    names = archive.namelist()
    if not any(name.startswith("shaders/") for name in names):
        raise SystemExit("Invalid archive: shaders/ folder missing")
print(f"Created {OUT}")