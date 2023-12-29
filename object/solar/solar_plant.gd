extends Producer


func _physics_process(_delta: float) -> void:
	if (weather.is_night()):
		active_capability_out = 0
		current_power = 0
	else:
		active_capability_out = calculate_power_output(weather._get_sun_strength())
		current_power = clampf(active_capability_out, dmol, nominal_power)
	
func calculate_power_output(point_of_day: float) -> float:
	return lerp(0.0, nominal_power, point_of_day)
