# HYPERREAL SHADERS

Original Minecraft Java shader-pack project targeting **Minecraft 1.20.4 + Iris + Sodium**. The pack uses the Iris/OptiFine shader-pack layout and GLSL 330 compatibility shaders.

> **Development status: v0.1.0-alpha foundation.** This is a real shader-pack baseline, not a claim that every feature in the long-term vision is finished. The first build focuses on terrain rendering, a shadow-map pass, screen-space shadow filtering, and restrained post-processing. Volumetric clouds, physically based water/refraction, temporal GI, and full PBR are not implemented yet.

## Current implementation

- Terrain G-buffer pass preserving Minecraft's texture and lightmap inputs.
- Shadow-map geometry pass and 3x3 PCF shadow lookup in the composite pass.
- Distance-based atmospheric tint approximation.
- Lightweight four-tap highlight bloom.
- Screen-space sun-ray approximation, gated by depth.
- Linear-light color pipeline (sRGB decode → lighting/tone mapping → sRGB encode) to prevent washed-out output.
- Conservative exposure, restrained highlight bloom, and subtle vignette.
- Quality profiles from LOW through CINEMATIC.

## Compatibility

- Target: Minecraft Java Edition 1.20.4.
- Intended loader: Iris Shaders with Sodium.
- OptiFine compatibility is best-effort and has not been runtime-tested.
- GLSL: GLSL 330 compatibility.
- GPU: OpenGL 3.3-class hardware or newer recommended.

## Install

1. Install Minecraft Java 1.20.4, Iris, and a compatible Sodium version.
2. Download the HYPERREAL-SHADERS.zip artifact from repository Actions → Build Shader Pack.
3. Put the ZIP directly in .minecraft/shaderpacks/ (do not extract it).
4. Select HYPERREAL SHADERS in Video Settings → Shader Packs.
5. Start with MEDIUM or HIGH. Lower shadow resolution if performance is poor.

## Settings

The shader options are exposed through shaders/shaders.properties. Available controls include shadow-map resolution, shadow distance, bloom, distant fog, sun rays, and shadow filtering. Presets: LOW, MEDIUM, HIGH, ULTRA, EXTREME, CINEMATIC.

## Build locally

Python 3.10+ is sufficient for packaging and structural validation:

    python tools/validate_pack.py
    python tools/package_pack.py

The ZIP has the shader-pack root at its top level, so it can be copied directly into shaderpacks.

## Recent visual fix

The composite pass previously tone-mapped display-encoded colors without first converting them to linear light. This caused midtones to become excessively bright. The pass now performs the inverse gamma conversion before lighting and tone mapping, then converts back for display. This is a code-level correction; a full Minecraft/Iris runtime screenshot test is still required.

## Honest limitations

A conventional Iris shader pack does not provide hardware ray tracing access. The current shadows are shadow-map based; the sun-ray effect is a screen-space approximation; fog is a depth-based color blend rather than physically integrated volumetrics. The current pack does not yet implement volumetric cloud ray marching, SSR, SSGI, true refractive glass, water caustics, temporal accumulation, or a complete PBR material pipeline.

## License

Project source: MIT License. Any future third-party code or assets must retain their original license and attribution. No third-party shader-pack source is bundled in this repository.