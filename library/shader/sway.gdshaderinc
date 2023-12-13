group_uniforms Sway;
uniform vec2 wind_vector = vec2(0.002, 0.002); // vec2(x, z)alpha_scissor_threshold
uniform float sway_radius = 0.01; // Determines the sway arc
uniform float sway_cycle_time = 5.0; // How long it takes to sway a full circle
group_uniforms;

vec3 get_sway(vec3 vertex, vec3 node_position_world) {
	// Make sure swaying trees don't synchronize.
	// TODO: Without this, trees don't synchronize either. Is VERTEX.x in world coords maybe?
	float position_factor = node_position_world.x * node_position_world.z;
	
	int current_time_ms = int(position_factor + TIME * 1000.0);
	int full_cycle_ms = int(position_factor + sway_cycle_time * 1000.0);
	float x = 1.0 - (2.0 * float(current_time_ms % full_cycle_ms)) / float(full_cycle_ms);
	float sway_sine = sway_radius * sin(x * PI) + wind_vector.x;
	float sway_cosine = sway_radius * cos(x * PI) + wind_vector.y;
	
	// Top of the tree should sway harder than the bottom, hence vertex.y.
	return vec3(sway_sine * (node_position_world.y + vertex.y),
				0.0,
				sway_cosine * (node_position_world.y + vertex.y));
}