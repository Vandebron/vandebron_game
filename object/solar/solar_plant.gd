extends Producer


func _ready() -> void:
	super()


func _physics_process(_delta: float) -> void:
	if weather.is_night():
		active_capability_out = 0.0
		current_power = 0.0
	else:
		active_capability_out = _calculate_power_output(weather.sun_strength)
		current_power = clampf(active_capability_out, dmol, nominal_power)


func _calculate_power_output(sun_strength: float) -> float:
	if disabled:
		return 0.0
	return lerpf(0.0, nominal_power, sun_strength)
