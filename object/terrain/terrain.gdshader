shader_type spatial;
render_mode diffuse_toon;

group_uniforms Ground;
uniform vec3 main_color: source_color = vec3(0.0);
uniform vec3 second_color: source_color = vec3(1.0);
// Determines where secondary color is placed
uniform sampler2D splatmap_texture: source_color;
// Dictates how much of secondary color is shown
uniform float edge: hint_range(0.0, 1.0, 0.01) = 0.5;
group_uniforms;

group_uniforms Grid;
uniform float cell_size = 1.0;
uniform vec2 offset = vec2(0.0);
uniform float line_width = 0.1;
uniform vec4 line_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec3 pointer_world_pos;
uniform float pointer_circle_size = 1.5;
uniform vec4 pointer_circle_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float ripple_ampl = 5.0;
uniform float ripple_freq = 2.0;
uniform float ripple_factor = 10.0;
group_uniforms;

varying vec2 fragment_world_pos;

void vertex() {
	fragment_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

void fragment() {
	float line_ratio = line_width / cell_size;
	// The fractional part of the position within the current cell, adjusted by the line width.
	vec2 pos_in_cell = fract((fragment_world_pos + offset) / cell_size + line_ratio / 2.0);
	// 1.0 if current fragment is a on line, 0.0 otherwise.
	float is_line = step(line_ratio, pos_in_cell.x) * step(line_ratio, pos_in_cell.y);

	if (is_line * line_color.a > 0.0) {
		// Here we're drawing the ground
		vec4 splatmap = texture(splatmap_texture, UV);
		float main_or_second = step(edge, splatmap.r);

		ALBEDO = mix(second_color, main_color, main_or_second);
	} else {
		// Here we're drawing the grid lines
		float dist = distance(pointer_world_pos.xz, fragment_world_pos);
		float ripple = sin(dist * ripple_ampl - TIME * ripple_freq) * ripple_factor;
		float pointer_circle_opacity = max(0.0, 1.0 - (dist / pointer_circle_size) + ripple);
		// TODO: These two steps should be able to be merged into one
		pointer_circle_opacity = (1.0 - (dist / pointer_circle_size)) * pointer_circle_opacity;
		pointer_circle_opacity = step(1.0, pointer_circle_opacity);

		ALBEDO = mix(line_color.rgb, pointer_circle_color.rgb, pointer_circle_opacity);
	}
}
