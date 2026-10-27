shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float grain_strength = 0.05;
uniform float vignette_strength = 0.36;
uniform float dither_strength = 0.4;
uniform float chroma_strength = 0.0006;
uniform bool effects_enabled = true;

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec3 col = texture(screen_tex, uv).rgb;
	if (effects_enabled) {
		if (chroma_strength > 0.0) {
			col.r = texture(screen_tex, uv + vec2(chroma_strength, 0.0)).r;
			col.b = texture(screen_tex, uv - vec2(chroma_strength, 0.0)).b;
		}
		float grain = hash21(uv * vec2(1280.0, 720.0) + fract(TIME) * 17.0);
		col += (grain - 0.5) * grain_strength;
		float dither = hash21(floor(FRAGCOORD.xy));
		col += (dither - 0.5) * dither_strength * 0.03;
		vec2 centered = uv - vec2(0.5);
		float vig = smoothstep(0.95, 0.28, dot(centered, centered));
		col *= mix(1.0, vig, vignette_strength);
		col *= vec3(1.05, 0.97, 0.88);
	}
	COLOR = vec4(clamp(col, vec3(0.0), vec3(1.0)), 1.0);
}
