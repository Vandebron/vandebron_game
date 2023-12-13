shader_type spatial;
render_mode blend_mix, diffuse_toon, depth_prepass_alpha, cull_back;

uniform vec3 albedo: source_color = vec3(1.0);
uniform float transparency: hint_range(0.0, 1.0, 0.1) = 0.0;
uniform float roughness: hint_range(0.0, 1.0, 0.1) = 1.0;

#include "res://library/shader/sway.gdshaderinc"

void vertex() {
	vec3 sway = get_sway(VERTEX, NODE_POSITION_WORLD);
	VERTEX.x += sway.x;
	VERTEX.z += sway.z;
}

void fragment() {
	ALBEDO = albedo.rgb;
	ROUGHNESS = roughness;
	ALPHA = 1.0 - transparency;
}
