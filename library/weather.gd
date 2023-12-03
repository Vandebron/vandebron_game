extends Node

const wind_cycle_ms: int = 30000 # Dictates how long it takes for weather to repeat

var wind: float = 0.5 # Ranges from 0-1
var sun: float = 0.5 # Ranges from 0-1

var _target_wind: float = 1.0


func _ready() -> void:
	_update_wind()


func _physics_process(delta: float) -> void:
	wind = lerpf(wind, _target_wind, delta)


func _update_wind() -> void:
	get_tree().create_timer(1.0).timeout.connect(self._update_wind)
	
	# This curve is a simple sine wave with no variance.
	# TODO: We could use a Godot Curve (built-in) to have a deterministic weather pattern with some
	#		variability to make it look random.
	var x: float = _get_curve_x()
	var y: float = _get_curve_y(x)
	_target_wind = y


func _get_curve_x() -> float:
	var current_time_ms: int = Time.get_ticks_msec()
	return 1.0 - (2.0 * (current_time_ms % wind_cycle_ms)) / wind_cycle_ms


## Returns a value between 0 and 1.
## Input value of -1 yields 0, 0 yield 0.5, 1 yields 1.
func _get_curve_y(x: float) -> float:
	return .5 * cos(x * PI) + .5
