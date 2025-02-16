shader_type spatial;
render_mode shadows_disabled, specular_disabled;

//#define LINE_CONTRAST
//#define RIPPLE_ON_SURFACE

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

	float dist = distance(pointer_world_pos.xz, fragment_world_pos);
	float ripple = sin(dist * ripple_ampl - TIME * ripple_freq) * ripple_factor;
	float pointer_circle_opacity = max(0.0, 1.0 - (dist / pointer_circle_size) + ripple);
	// TODO: These two steps should be able to be merged into one
	pointer_circle_opacity = (1.0 - (dist / pointer_circle_size)) * pointer_circle_opacity;
	pointer_circle_opacity = step(1.0, pointer_circle_opacity);

#ifdef LINE_CONTRAST
	vec3 contrast = (pointer_circle_color.rgb - line_color.rgb) * 5.0;
	ALBEDO = line_color.rgb + contrast * pointer_circle_opacity;
#else
	ALBEDO = mix(line_color.rgb, pointer_circle_color.rgb, pointer_circle_opacity);
#endif

	ALPHA = (1.0 - is_line) * line_color.a;
#ifdef RIPPLE_ON_SURFACE
	ALPHA = mix(ALPHA, line_color.a, pointer_circle_opacity);
#endif
}
