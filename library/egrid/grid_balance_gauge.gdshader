shader_type canvas_item;

uniform float supply = 10.0;
uniform float demand = 10.0;
uniform float balance = 1.0;
uniform float balance_line_width = 1.0;
uniform float freq_margin = 0.05;
uniform float freq_margin_line_width = 0.01;
uniform vec3 freq_margin_line_color : source_color = vec3(1.0, 0.0, 0.0);
//uniform vec3 balance_line_color : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 supply_color : source_color = vec3(0.0);
uniform vec3 demand_color : source_color = vec3(1.0);

void fragment() {
	if (UV.x > (balance * .5) - (0.01 * .5) && UV.x < (balance * .5) + (0.01 * .5)) {
		const vec3 red = vec3(1.0, 0.0, 0.0);
		const vec3 green = vec3(0.0, 1.0, 0.0);
		COLOR.rgb = mix(green, red, abs(fract(1.0 - balance)) / freq_margin);
	} else if (UV.x > 0.5 - freq_margin - freq_margin_line_width * .5 && UV.x < 0.5 - freq_margin + freq_margin_line_width * .5) {
		COLOR.rgb = freq_margin_line_color;
	} else if (UV.x > 0.5 + freq_margin - freq_margin_line_width * .5 && UV.x < 0.5 + freq_margin + freq_margin_line_width * .5) {
		COLOR.rgb = freq_margin_line_color;
	} else {
		float what_to_draw = step(supply / (supply + demand), UV.x);
		COLOR.rgb = mix(supply_color, demand_color, what_to_draw);
	}
}
