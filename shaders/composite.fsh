#version 330 compatibility
#define SHADOWS // Enable shadow-map lighting
#define BLOOM // Enable highlight bloom
#define DISTANT_FOG // Enable distance atmosphere
#define GOD_RAYS // Enable screen-space sun rays
uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform mat4 gbufferProjection;
uniform vec3 sunPosition;
uniform float viewWidth;
uniform float viewHeight;
uniform float shadowMapResolution;
uniform float near;
uniform float far;
uniform float rainStrength;
uniform int worldTime;
in vec2 texcoord;
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 fragColor;

float linearDepth(float depth) {
    float z = depth * 2.0 - 1.0;
    return (2.0 * near * far) / max(far + near - z * (far - near), 0.0001);
}
float sampleShadow(vec3 viewPosition) {
#ifdef SHADOWS
    vec4 worldPosition = gbufferModelViewInverse * vec4(viewPosition, 1.0);
    vec4 shadowClip = shadowProjection * shadowModelView * worldPosition;
    vec3 shadowNdc = shadowClip.xyz / max(shadowClip.w, 0.0001);
    vec3 shadowUv = shadowNdc * 0.5 + 0.5;
    if (shadowUv.x < 0.002 || shadowUv.x > 0.998 ||
        shadowUv.y < 0.002 || shadowUv.y > 0.998 ||
        shadowUv.z < 0.0 || shadowUv.z > 1.0) return 1.0;
    float visibility = 0.0;
    vec2 texel = vec2(1.0 / max(shadowMapResolution, 1.0));
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            float storedDepth = texture(shadowtex0, shadowUv.xy + vec2(x, y) * texel).r;
            visibility += step(shadowUv.z - 0.0018, storedDepth);
        }
    }
    return mix(0.42, 1.0, visibility / 9.0);
#else
    return 1.0;
#endif
}
vec3 acesFit(vec3 x) {
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}
vec3 bloomSample(vec2 uv) {
    vec2 px = 1.0 / vec2(viewWidth, viewHeight);
    vec3 sum = vec3(0.0);
    sum += max(texture(colortex0, uv + vec2( px.x, 0.0)).rgb - 0.82, 0.0);
    sum += max(texture(colortex0, uv + vec2(-px.x, 0.0)).rgb - 0.82, 0.0);
    sum += max(texture(colortex0, uv + vec2(0.0,  px.y)).rgb - 0.82, 0.0);
    sum += max(texture(colortex0, uv + vec2(0.0, -px.y)).rgb - 0.82, 0.0);
    return sum * 0.25;
}
void main() {
    vec3 scene = texture(colortex0, texcoord).rgb;
    float depth = texture(depthtex0, texcoord).r;
#ifdef SHADOWS
    if (depth < 0.99999) {
        vec4 clipPosition = vec4(texcoord * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
        vec4 viewPosition = gbufferProjectionInverse * clipPosition;
        viewPosition /= max(viewPosition.w, 0.0001);
        scene *= sampleShadow(viewPosition.xyz);
    }
#endif
#ifdef DISTANT_FOG
    float fogAmount = smoothstep(0.58, 0.99, depth) * 0.32;
    float dayFactor = smoothstep(0.0, 0.5, float(worldTime) / 24000.0);
    vec3 fogColor = mix(vec3(0.56, 0.66, 0.78), vec3(0.76, 0.64, 0.52), dayFactor);
    fogAmount *= (1.0 - rainStrength * 0.35);
    scene = mix(scene, fogColor, fogAmount);
#endif
#ifdef BLOOM
    scene += bloomSample(texcoord) * 0.16;
#endif
#ifdef GOD_RAYS
    vec4 sunClip = gbufferProjection * vec4(normalize(sunPosition), 1.0);
    vec2 sunUv = sunClip.xy / max(sunClip.w, 0.0001) * 0.5 + 0.5;
    vec2 rayVector = (sunUv - texcoord) * 0.045;
    float rays = 0.0;
    vec2 sampleUv = texcoord;
    for (int i = 0; i < 8; i++) {
        sampleUv += rayVector;
        float sampleDepth = texture(depthtex0, clamp(sampleUv, 0.001, 0.999)).r;
        rays += smoothstep(0.997, 1.0, sampleDepth);
    }
    float sunMask = 1.0 - smoothstep(0.0, 0.2, distance(texcoord, sunUv));
    scene += vec3(1.0, 0.78, 0.48) * rays * sunMask * 0.006;
#endif
    vec2 centered = texcoord * 2.0 - 1.0;
    float vignette = 1.0 - dot(centered, centered) * 0.055;
    scene *= clamp(vignette, 0.82, 1.0);
    scene = acesFit(scene * 1.06);
    scene = pow(scene, vec3(1.0 / 2.2));
    fragColor = vec4(scene, 1.0);
}