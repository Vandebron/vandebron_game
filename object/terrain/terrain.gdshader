shader_type spatial;
render_mode diffuse_toon;

uniform vec3 main_color: source_color = vec3(0.0);
uniform vec3 second_color: source_color = vec3(1.0);
// Determines where secondary color is placed
uniform sampler2D splatmap_texture: source_color;
// Dictates how much of secondary color is shown
uniform float edge: hint_range(0.0, 1.0, 0.01) = 0.5;

void fragment() {
	vec4 splatmap = texture(splatmap_texture, UV);
	float main_or_second = step(edge, splatmap.r);
	ALBEDO.rgb = mix(second_color, main_color, main_or_second);
}
