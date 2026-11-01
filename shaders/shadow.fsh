#version 330 compatibility
uniform sampler2D gtexture;
in vec2 vTexCoord;
in vec4 vColor;
layout(location = 0) out vec4 fragColor;
void main() {
    vec4 albedo = texture(gtexture, vTexCoord) * vColor;
    if (albedo.a < 0.1) discard;
    fragColor = albedo;
}