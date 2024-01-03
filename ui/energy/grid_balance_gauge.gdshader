shader_type canvas_item;

group_uniforms Colors;
uniform vec3 balance_line_good_color : source_color = vec3(1.0);
uniform vec3 balance_line_bad_color : source_color = vec3(0.0);
uniform vec3 background_color : source_color = vec3(0.0);
uniform vec3 freq_max_deviation_line_color : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 freq_max_deviation_bg_color : source_color = vec3(1.0, 0.0, 0.0);
group_uniforms;

group_uniforms Frequency;
uniform float current_hz = 50.0;
uniform float target_hz = 50.0;
uniform float gauge_range_hz = 0.5;
uniform float current_hz_line_width = 0.01;
group_uniforms;

group_uniforms FrequencyDeviation;
uniform float freq_max_deviation = 0.1;
uniform float freq_max_deviation_line_width = 0.01;
uniform bool freq_max_show_as_lines;
group_uniforms;

void fragment() {
	float current_freq_hz = clamp(current_hz, target_hz - gauge_range_hz, target_hz + gauge_range_hz);
	float x = UV.x + (target_hz - gauge_range_hz);

	float in_current_range =
		  step(current_freq_hz - (current_hz_line_width * 0.5), x)
		* step(x, current_freq_hz + (current_hz_line_width * 0.5));
	float in_tolerance_range =
		  step(target_hz - freq_max_deviation, x)
		* step(x, target_hz + freq_max_deviation);

	if (in_current_range > 0.0) {
		COLOR.rgb = mix(balance_line_good_color, balance_line_bad_color,
			fract(abs(target_hz - current_freq_hz)) / freq_max_deviation);
	} else if (in_tolerance_range > 0.0) {
		if (freq_max_show_as_lines) {
			float lower_bound_line =
				  step(target_hz - freq_max_deviation - (freq_max_deviation_line_width * 0.5), x)
				* step(x, target_hz - freq_max_deviation + (freq_max_deviation_line_width * 0.5));
			float upper_bound_line =
				  step(target_hz + freq_max_deviation - (freq_max_deviation_line_width * 0.5), x)
				* step(x, target_hz + freq_max_deviation + (freq_max_deviation_line_width * 0.5));

			COLOR.rgb = mix(background_color, freq_max_deviation_line_color,
				max(lower_bound_line, upper_bound_line));
		} else {
			COLOR.rgb = freq_max_deviation_bg_color;
		}
	} else {
		COLOR.rgb = background_color;
	}
}
