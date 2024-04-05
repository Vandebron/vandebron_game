shader_type canvas_item;
/*
 * Specific UI bar that displays the distribution of energy types on the grid.
 */

group_uniforms Energy;
uniform float fossil = 10.0;
uniform float solar = 10.0;
uniform float wind = 10.0;
uniform float battery = 10.0;
uniform float demand = 40.0;
group_uniforms;

group_uniforms Colors;
uniform vec3 fossil_color : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 solar_color : source_color = vec3(0.0, 1.0, 0.0);
uniform vec3 wind_color : source_color = vec3(0.0, 0.0, 1.0);
uniform vec3 battery_color : source_color = vec3(0.0, 1.0, 1.0);
uniform vec3 demand_color : source_color = vec3(1.0);
group_uniforms;

void fragment() {
	float supply = fossil + solar + wind;
	float total = supply + demand;
	
	float fossil_pct = fossil / total;
	float solar_pct = solar / total;
	float wind_pct = wind / total;
	float battery_pct = battery / total;
	float demand_pct = demand / total;

	vec3 final = vec3(0.0);
	final = mix(fossil_color,	final, step(UV.x, 0.0));
	final = mix(solar_color,	final, step(UV.x, fossil_pct));
	final = mix(wind_color,		final, step(UV.x, fossil_pct + solar_pct));
	final = mix(battery_color,	final, step(UV.x, fossil_pct + solar_pct + wind_pct));
	final = mix(demand_color,	final, step(UV.x, fossil_pct + solar_pct + wind_pct + battery_pct));
	COLOR.rgb = final;
}
