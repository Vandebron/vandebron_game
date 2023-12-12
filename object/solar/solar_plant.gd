extends Producer

var _speed: float = 1.0
var _target_output: float = 1.0
var _variance: float = 0.1 # Represents random production deviation per windmill

func _init() -> void:
	add_to_group(Constants.GROUP_PRODUCER)

func _physics_process(delta: float) -> void:
	_target_output = clampf(Weather.sun - _variance, 0.0, 1.0)
	active_capability_out = _target_output * nominal_power
	current_power = clampf(_speed * active_capability_out, dmol, nominal_power)
