extends Node

enum Season {AUTUMN, WINTER, SPRING, SUMMER}

const days_per_season: int = 7
const day_night_cycle: Curve = preload("res://library/day_night_cycle.tres")
const day_night_cycle_ms: int = 30_000 # Cycle of 30 seconds means day=15s, night=15s
const wind_cycle_ms: int = 30_000 # Dictates how long it takes for weather to repeat
const min_temperature: float = -10.0
const max_temperature: float = 40.0

var wind_angle: float = 1.0 # Direction of wind in radians. Cosmetic. does not affect wind power
var wind: float = 0.5 # Ranges from 0-1
var sun: float = 0.5 # Ranges from 0-1
var point_of_day: float = 0.0 # Ranges from 0-1; night is > 0.5
var temperature: float = 0.0 # Ranges from 0-1; let's say 0=-10, 1=40

var _target_wind: float = 1.0
var _was_night: bool
var _days_passed: int
var _season: Season


func _ready() -> void:
	_update_wind()
	_update_temperature()


func _physics_process(delta: float) -> void:
	point_of_day = _get_point_of_day()
	wind = lerpf(wind, _target_wind, delta)
	temperature = point_of_day
	
	if is_night() && !_was_night:
		_was_night = true
		Events.night_started.emit()
	elif !is_night() && _was_night:
		_was_night = false
		Events.night_ended.emit()
		
		_days_passed += 1
		# Increment season every X days, and make sure it wraps around from summer to autumn.
		if _days_passed % days_per_season == 0:
			_season = wrapi(_season + 1, 0, Season.size()) as Season


func _update_wind() -> void:
	get_tree().create_timer(1.0).timeout.connect(self._update_wind)
	
	# This curve is a simple sine wave with no variance.
	# TODO: We could use a Godot Curve (built-in) to have a deterministic weather pattern with some
	#		variability to make it look random.
	var x: float = Utils.get_cycle_value(wind_cycle_ms)
	var y: float = Utils.sine_y(x)
	_target_wind = y
	
	wind_angle = PI * randf_range(-6.0, 6.0)


func _update_temperature() -> void:
	get_tree().create_timer(1.0).timeout.connect(self._update_temperature)
	
	# TODO: Add sun strength as additional factor for temperature maybe?
	temperature = _limit_temperature(point_of_day)


func _limit_temperature(temp: float) -> float:
	match _season:
		Season.AUTUMN:
			return clampf(temp, celcius_to_temp(5.0), celcius_to_temp(15.0))
		Season.WINTER:
			return clampf(temp, celcius_to_temp(-10.0), celcius_to_temp(8.0))
		Season.SPRING:
			return clampf(temp, celcius_to_temp(10.0), celcius_to_temp(23.0))
		Season.SUMMER:
			return clampf(temp, celcius_to_temp(12.0), celcius_to_temp(40.0))
	printerr("Unknown season")
	return 0.5


func is_day() -> bool:
	return point_of_day >= 0.5


func is_night() -> bool:
	return point_of_day < 0.5


func celcius_to_temp(celcius: float) -> float:
	return (celcius + min_temperature) / (max_temperature - min_temperature)


func temp_to_celcius(temp: float) -> float:
	return (temp * (max_temperature - min_temperature)) - min_temperature


func _get_point_of_day() -> float:
	# We rotate the sun based on PI, so we need to account for that here
	var x: float = Utils.get_cycle_value(int(day_night_cycle_ms * PI))
	return day_night_cycle.sample(absf(x))
