shader_type canvas_item;
/*
 * Specific UI bar that displays current and potential energy produced/consumed by the energy grid
 */

uniform bool show_details;

group_uniforms Energy;
uniform float fossil = 10.0;
uniform float solar = 10.0;
uniform float wind = 10.0;
uniform float demand = 10.0;
group_uniforms;

group_uniforms Colors;
uniform vec3 fossil_color : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 solar_color : source_color = vec3(0.0, 1.0, 0.0);
uniform vec3 wind_color : source_color = vec3(0.0, 0.0, 1.0);
uniform vec3 supply_color : source_color = vec3(0.0);
uniform vec3 demand_color : source_color = vec3(1.0);
group_uniforms;

group_uniforms Frequency;
uniform float current_hz = 50.0;
uniform float target_hz = 50.0;
uniform float gauge_range_hz = 0.5; // If 0.5, the gauge will show values between 49.5 and 50.5 Hz
uniform float balance_line_width = 0.01;
group_uniforms;

group_uniforms FrequencyDeviation;
uniform float freq_max_deviation = 0.1;
uniform float freq_max_deviation_line_width = 0.01;
uniform vec3 freq_max_deviation_line_color : source_color = vec3(1.0, 0.0, 0.0);
group_uniforms;

void fragment() {
	float supply = fossil + solar + wind;
	float total = supply + demand;
	float current_freq_hz = clamp(current_hz, target_hz - gauge_range_hz, target_hz + gauge_range_hz);
	float x = UV.x + (target_hz - gauge_range_hz);
	
	if (x > current_freq_hz - (balance_line_width * 0.5)
	 && x < current_freq_hz + (balance_line_width * 0.5)
	) {
		// If we end up here, we're drawing the line that represents the current grid frequency.
		// When the current_freq_hz is within the tolerance margins, it will be green; red otherwise.
		const vec3 red = vec3(1.0, 0.0, 0.0);
		const vec3 green = vec3(0.0, 1.0, 0.0);
		COLOR.rgb = mix(green, red, fract(abs(target_hz - current_freq_hz)) / freq_max_deviation);
	} else if (x > target_hz - freq_max_deviation - (freq_max_deviation_line_width * 0.5)
			&& x < target_hz - freq_max_deviation + (freq_max_deviation_line_width * 0.5)
	) {
		// This line designates the grid frequency tolerance margin - lower bound.
		COLOR.rgb = freq_max_deviation_line_color;
	} else if (x > target_hz + freq_max_deviation - (freq_max_deviation_line_width * 0.5)
			&& x < target_hz + freq_max_deviation + (freq_max_deviation_line_width * 0.5)
	) {
		// This line designates the grid frequency tolerance margin - upper bound.
		COLOR.rgb = freq_max_deviation_line_color;
	} else if (show_details) {
		// When you turn on the show_details flag, the gauge will show all energy production as
		// separate colors.
		
		float fossil_pct = fossil / total;
		float solar_pct = solar / total;
		float wind_pct = wind / total;
		float demand_pct = demand / total;

		vec3 final = vec3(0.0);
		final = mix(fossil_color,	final, step(UV.x, 0.0));
		final = mix(solar_color,	final, step(UV.x, fossil_pct));
		final = mix(wind_color,		final, step(UV.x, fossil_pct + solar_pct));
		final = mix(demand_color,	final, step(UV.x, fossil_pct + solar_pct + wind_pct));
		COLOR.rgb = final;
	} else {
		// When the show_details flag is off, it will simply show supply vs demand.
		COLOR.rgb = mix(supply_color, demand_color, step(supply / total, UV.x));
	}
}
