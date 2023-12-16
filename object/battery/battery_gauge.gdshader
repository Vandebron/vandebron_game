shader_type spatial;
render_mode diffuse_toon;

uniform float charge_percentage: hint_range(0.0, 1.0, 0.1) = 0.5;
uniform vec3 charge_color: source_color = vec3(1.0);
uniform vec3 empty_color: source_color = vec3(0.0);

varying float normalized_vertex_y;

void vertex() {
	// TODO: This feels wrong. I just want the vertex.y relative to the total model height.
	//		 This is probably not the way to do that. But it works nonetheless.
	normalized_vertex_y = 1.0 - (0.5 - VERTEX.y);
}

void fragment() {
	ALBEDO = mix(charge_color, empty_color, step(charge_percentage, normalized_vertex_y));
}
