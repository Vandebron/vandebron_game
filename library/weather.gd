extends Node

const day_night_cycle: Curve = preload("res://library/day_night_cycle.tres")
const day_night_cycle_ms: int = 30_000 # Cycle of 30 seconds means day=15s, night=15s
const wind_cycle_ms: int = 30_000 # Dictates how long it takes for weather to repeat

var wind: float = 0.5 # Ranges from 0-1
var sun: float = 0.5 # Ranges from 0-1
var point_of_day: float = 0.0 # Ranges from 0-1; night is > 0.5

var _target_wind: float = 1.0
var _was_night: bool


func _ready() -> void:
	_update_wind()


func _physics_process(delta: float) -> void:
	wind = lerpf(wind, _target_wind, delta)
	point_of_day = _get_point_of_day()
	
	if is_night() && !_was_night:
		_was_night = true
		Events.night_started.emit()
	elif !is_night() && _was_night:
		_was_night = false
		Events.night_ended.emit()


func _update_wind() -> void:
	get_tree().create_timer(1.0).timeout.connect(self._update_wind)
	
	# This curve is a simple sine wave with no variance.
	# TODO: We could use a Godot Curve (built-in) to have a deterministic weather pattern with some
	#		variability to make it look random.
	var x: float = Utils.get_cycle_value(wind_cycle_ms)
	var y: float = Utils.sine_y(x)
	_target_wind = y


func is_day() -> bool:
	return point_of_day <= 0.5


func is_night() -> bool:
	return point_of_day > 0.5


func _get_point_of_day() -> float:
	# We rotate the sun based on PI, so we need to account for that here
	var x: float = Utils.get_cycle_value(int(day_night_cycle_ms * PI))
	return day_night_cycle.sample(absf(x))
