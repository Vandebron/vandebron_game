shader_type canvas_item;

group_uniforms Colors;
uniform vec3 background_color : source_color = vec3(0.0);
uniform vec3 current_hz_line_color : source_color = vec3(1.0);
uniform vec3 freq_max_deviation_bg_color : source_color = vec3(1.0, 0.0, 0.0);
group_uniforms;

group_uniforms Frequency;
uniform float current_hz = 50.0;
uniform float target_hz = 50.0;
uniform float gauge_range_hz = 0.5;
uniform float current_hz_line_width = 0.05;
uniform float freq_max_deviation = 0.1;
group_uniforms;

group_uniforms Arc;
uniform float angle_start : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float angle_end : hint_range(0.0, 2.0, 0.1) = 2.0;
uniform float inner_radius = 0.5;
uniform float outer_radius = 1.0;
uniform float outline_width : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform vec3 outline_color : source_color = vec3(0.0);
uniform float arc_smoothness : hint_range(0.0, 0.4, 0.001) = 0.01;
uniform bool full_circle;
group_uniforms;

#include "res://library/shader/arc.gdshaderinc"

// Used for outline
const vec2 top_left = vec2(-1.0, -1.0);
const vec2 top_center = vec2(0.0, -1.0);
const vec2 top_right = vec2(1.0, -1.0);
const vec2 bottom_left = vec2(-1.0, 1.0);
const vec2 bottom_center = vec2(0.0, 1.0);
const vec2 bottom_right = vec2(1.0, 1.0);
const vec2[] offsets = {top_left, top_center, top_right, bottom_left, bottom_center, bottom_right};

void fragment() {
	const float angle_offset = 1.0; // 1.0 will make everything point downwards.
	vec2 coords;
	
	if (full_circle) {
		// Normalize UV.x between -1 and 1.
		coords = UV * 2.0 - 1.0;
	} else {
		// Normalize UV.x between -1 and 1.
		// But leave UV.y alone, because we want to draw just half an arc.
		coords = vec2(UV.x * 2.0 - 1.0, UV.y);
	}
	
	// Check if we are drawing the "frequency max deviation" range.
	float normalized_freq_deviation = freq_max_deviation * 0.5 / gauge_range_hz;
	float freq_range_start = angle_offset + (0.5 - normalized_freq_deviation);
	float freq_range_end = angle_offset + (0.5 + normalized_freq_deviation);
	float freq_deviation_angle = in_angle(coords, freq_range_start, freq_range_end, arc_smoothness);
	float is_freq_deviation_range = 1.0 - step(freq_deviation_angle, UV.y);
	
	// Check if we are drawing the "current hz" line.
	float normalized_current_hz = 1.0 - (0.5 + (current_hz - target_hz) / gauge_range_hz * 0.5);
	float current_hz_start = angle_offset + normalized_current_hz - current_hz_line_width;
	float current_hz_end = angle_offset + normalized_current_hz + current_hz_line_width;
	float current_hz_range = in_angle(coords, current_hz_start, current_hz_end, arc_smoothness);
	float is_current_hz_line = 1.0 - step(current_hz_range, UV.y);
	
	if (is_current_hz_line > 0.0) {
		COLOR.rgb = current_hz_line_color;
	} else if (is_freq_deviation_range > 0.0) {
		COLOR.rgb = freq_max_deviation_bg_color;
	} else {
		COLOR.rgb = background_color;
	}
	
	float circle_alpha = in_angle(coords, angle_start, angle_end, arc_smoothness);
	float arc_alpha = in_arc(coords, inner_radius, outer_radius, arc_smoothness);
	float is_inside_arc_band = arc_alpha * circle_alpha;
	float alpha = is_inside_arc_band;
	
	// Add an outline
	for (int i = 0; i < offsets.length(); i++) {
		vec2 offset = offsets[i] * outline_width;
		arc_alpha = 1.0 - in_arc(coords, inner_radius - offset.x, outer_radius + offset.x, arc_smoothness);
		alpha = 1.0 - arc_alpha;
		COLOR.rgb = mix(COLOR.rgb, outline_color, 1.0 - alpha);
	}
	
	COLOR.a = alpha;
}
