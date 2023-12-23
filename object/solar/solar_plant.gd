extends Producer


func _physics_process(_delta: float) -> void:
	var production: float = weather.sun
	active_capability_out = production * nominal_power
	current_power = clampf(active_capability_out, dmol, nominal_power)
