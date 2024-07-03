shader_type spatial;
render_mode diffuse_toon, shadows_disabled;

uniform sampler2D albedo;
uniform vec3 color_a: source_color = vec3(1.0);
uniform vec3 color_b: source_color = vec3(0.8);
uniform float edge_min: hint_range(0.0, 1.0, 0.1) = 0.1;
uniform float edge_max: hint_range(0.0, 1.0, 0.1) = 0.2;
uniform float wave_speed: hint_range(0.0, 1.0, 0.001) = 0.002;
uniform vec2 wave_direction = vec2(1.0, 0.5);
uniform vec2 uv_scale = vec2(1.0);

void fragment() {
	int current_time = int(TIME * 1000.0);
	int full_cycle = int(10000.0);
	float x = 1.0 - (2.0 * float(current_time % full_cycle)) / float(full_cycle);
	float edge = 0.5 * sin(x * PI) + 0.5;
	edge = edge_min + edge * (edge_max - edge_min);

	vec2 uv = uv_scale * UV + ((TIME * wave_direction) * wave_speed);
	vec3 tex = texture(albedo, uv).rgb;
	ALBEDO = mix(color_a, color_b, step(edge, tex));
}
