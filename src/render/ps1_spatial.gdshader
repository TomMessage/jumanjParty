shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

uniform vec3 albedo_color : source_color = vec3(0.5);
uniform vec3 emission_color : source_color = vec3(0.0);
uniform float emission_energy = 0.0;
uniform float snap = 280.0;
uniform float affine_mix = 0.28;
uniform bool ps1_enabled = true;

varying vec3 warped_uv;
varying vec2 persp_uv;

void vertex() {
	vec4 view = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	if (ps1_enabled) {
		view.xyz = floor(view.xyz * snap + 0.5) / snap;
	}
	vec4 clip = PROJECTION_MATRIX * view;
	POSITION = clip;
	persp_uv = UV;
	warped_uv = vec3(UV * clip.w, clip.w);
}

void fragment() {
	vec2 affine = warped_uv.xy / max(warped_uv.z, 0.0001);
	float mix_amount = ps1_enabled ? affine_mix : 0.0;
	vec2 uv = mix(persp_uv, affine, mix_amount);
	float grit = fract(sin(dot(floor(uv * 24.0), vec2(12.9898, 78.233))) * 43758.5453);
	ALBEDO = albedo_color * mix(0.82, 1.0, grit);
	EMISSION = emission_color * emission_energy;
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
}
