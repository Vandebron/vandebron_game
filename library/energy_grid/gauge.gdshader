shader_type canvas_item;

uniform float current = 0.2;
uniform float target = 0.7;
uniform float line_width = 0.02;

uniform vec3 line_color : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 left_color : source_color = vec3(0.0);
uniform vec3 right_color : source_color = vec3(1.0);

void fragment() {
	if (UV.x > target - (line_width * .5) && UV.x < target + (line_width * .5)) {
		COLOR.rgb = line_color;
	} else {
		float what_to_draw = step(current / 1.0, UV.x);
		COLOR.rgb = mix(left_color, right_color, what_to_draw);
	}
}
