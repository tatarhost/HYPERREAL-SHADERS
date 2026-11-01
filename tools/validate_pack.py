#!/usr/bin/env python3
"""Structural checks for the HYPERREAL SHADERS pack (not a GLSL compiler)."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SHADERS = ROOT / "shaders"
REQUIRED = [
    "gbuffers_terrain.vsh", "gbuffers_terrain.fsh",
    "shadow.vsh", "shadow.fsh",
    "composite.vsh", "composite.fsh",
    "final.vsh", "final.fsh", "shaders.properties",
]

def fail(message: str) -> None:
    print(f"FAIL: {message}")
    sys.exit(1)

for rel in REQUIRED:
    path = SHADERS / rel
    if not path.is_file() or path.stat().st_size == 0:
        fail(f"missing or empty file: shaders/{rel}")

for path in SHADERS.rglob("*"):
    if path.is_file() and path.suffix in {".vsh", ".fsh", ".gsh", ".glsl"}:
        source = path.read_text(encoding="utf-8")
        if "#version 330 compatibility" not in source:
            fail(f"unexpected/missing GLSL version in {path.relative_to(ROOT)}")
        if source.count("{") != source.count("}"):
            fail(f"unbalanced braces in {path.relative_to(ROOT)}")
        if re.search(r"\bTODO\b|PLACEHOLDER|IMPLEMENT_ME", source):
            fail(f"placeholder found in {path.relative_to(ROOT)}")

props = (SHADERS / "shaders.properties").read_text(encoding="utf-8")
for profile in ("LOW", "MEDIUM", "HIGH", "ULTRA", "EXTREME", "CINEMATIC"):
    if f"profile.{profile} =" not in props:
        fail(f"missing quality profile: {profile}")

print("PASS: required shader stages, GLSL headers, brace balance, and profiles.")
print("NOTE: structural validation only; Iris runtime compilation is still required.")