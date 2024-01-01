shader_type spatial;
render_mode diffuse_toon;

uniform sampler2D snow_splatmap: source_color;
uniform float snow_density: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform vec3 ground_color: source_color = vec3(0.0);
uniform vec3 snow_color: source_color = vec3(1.0);

void fragment() {
	vec4 snow = texture(snow_splatmap, UV);
	float snow_or_ground = step(snow_density, snow.r);
	ALBEDO.rgb = mix(snow_color, ground_color, snow_or_ground);
}
