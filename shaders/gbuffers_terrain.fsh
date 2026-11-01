#version 330 compatibility
uniform sampler2D gtexture;
uniform sampler2D lightmap;
in vec2 vTexCoord;
in vec2 vLightmap;
in vec4 vColor;
in vec3 vViewNormal;
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 fragColor;
void main() {
    vec4 albedo = texture(gtexture, vTexCoord) * vColor;
    if (albedo.a < 0.1) discard;
    vec3 vanillaLight = texture(lightmap, vLightmap).rgb;
    float normalUp = clamp(vViewNormal.y * 0.5 + 0.5, 0.0, 1.0);
    float ambientLift = mix(0.88, 1.0, normalUp);
    fragColor = vec4(albedo.rgb * vanillaLight * ambientLift, albedo.a);
}