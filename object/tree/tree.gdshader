shader_type spatial;
render_mode specular_disabled, diffuse_toon, cull_back;

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
	
	// Normally we'd just do `ALPHA = 1.0 - transparency;`.
	// But that causes some quirks in the Godot Compatibility Renderer (WebGL).
	if (1.0 == step(0.5, transparency)) {
		discard;
	}
}
