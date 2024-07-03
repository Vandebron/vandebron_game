extends Producer

@onready var model: Model = $Model

var _target_power: float


func _ready() -> void:
	super()


func update_power(clock: Clock, weather: Weather) -> void:
	if clock.is_night():
		_target_power = 0.0
		current_power = 0.0
	else:
		_target_power = _calculate_power_output(weather.sun_strength)
		current_power = clampf(_target_power, 0.0, nominal_power)


func get_model() -> Model:
	return model


func _calculate_power_output(sun_strength: float) -> float:
	if disabled:
		return 0.0
	return lerpf(0.0, nominal_power, sun_strength)
