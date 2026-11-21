#version 460 core
#include <flutter/runtime_effect.glsl>

// Twinkles a baked glitter layer. Every grain cell gets its own speed and
// phase, so the field shimmers instead of pulsing in unison.

uniform vec2 uSize;      // size of the rect being drawn (units of FlutterFragCoord)
uniform float uTime;     // seconds
uniform float uGrain;    // grain cell size in image pixels
uniform float uImagePx;  // image side in pixels
uniform sampler2D uImage;

out vec4 fragColor;

float hash21(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec4 c = texture(uImage, uv);
  if (c.a <= 0.003) {
    fragColor = vec4(0.0);
    return;
  }

  vec2 cell = floor(uv * uImagePx / uGrain);
  float h1 = hash21(cell);
  float h2 = hash21(cell + 17.0);
  float h3 = hash21(cell + 91.0);

  // 0..1 wave with a per-grain speed and phase.
  float wave = 0.5 + 0.5 * sin(uTime * (1.5 + h2 * 3.5) + h1 * 6.2831853);

  // Soft shimmer on every grain, plus a sharp white flash on some of them.
  float shimmer = 0.82 + 0.28 * wave;
  float flash = pow(wave, 8.0) * smoothstep(0.35, 1.0, h3);

  // The image is premultiplied: white at this alpha is vec3(c.a).
  vec3 rgb = c.rgb * shimmer;
  rgb = mix(rgb, vec3(c.a), flash * 0.9);
  rgb = min(rgb, vec3(c.a));

  fragColor = vec4(rgb, c.a);
}
