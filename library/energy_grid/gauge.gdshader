shader_type canvas_item;
/*
 * Generic UI bar to represent both the active and potential state of things, like wind/solar/energy
 */

// These values don't have to be normalized to 0-1. That's what the max_value parameter is for.
uniform float current = 0.2; // Represents the current value
uniform float target = 0.7; // Represents the potential/target value
uniform float max_value = 1.0; // Represents the total/max value so we can normalize our values
uniform float line_width = 0.02;

uniform vec3 line_color : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 left_color : source_color = vec3(0.0);
uniform vec3 right_color : source_color = vec3(1.0);

void fragment() {
	float current_normalized = current / max_value;
	float target_normalized = target / max_value;
	float half_line_width = (line_width * 0.5);
	float is_current =
		step(UV.x, current_normalized + half_line_width)
		- step(UV.x, current_normalized - half_line_width);
	
	vec3 final = left_color; // By default, draw the "left" color.
	// We use a vertical line to represent the current value.
	final = mix(final, line_color, is_current);
	// Now decide whether to draw the "right" color, but make sure to not draw over the "current"
	// line, which is what the 'abs(1.0 - is_current)' part does.
	final = mix(final, right_color, step(target / max_value, UV.x) * abs(1.0 - is_current));
	COLOR.rgb = final;
}
