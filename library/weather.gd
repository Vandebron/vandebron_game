extends Node
class_name Weather

const wind_cycle_ms: int = 30_000 # Dictates how long it takes for weather to repeat
const min_temperature: float = -10.0
const max_temperature: float = 40.0

@export var clock: Clock

var wind_angle: float = 1.0 # Direction of wind in radians. Cosmetic. does not affect wind power
var wind: float = 0.5 # Ranges from 0-1
var sun: float = 0.5 # Ranges from 0-1
var sun_strength: float: get=_get_sun_strength # Ranges from 0-1
var temperature: float = 0.0 # Ranges from 0-1; let's say 0=-10, 1=40

var _target_wind: float = 1.0


func _ready() -> void:
	_update_wind()
	_update_temperature()


func _physics_process(delta: float) -> void:
	wind = lerpf(wind, _target_wind, delta)


func celcius_to_temp(celcius: float) -> float:
	return (celcius + min_temperature) / (max_temperature - min_temperature)


func temp_to_celcius(temp: float) -> float:
	return (temp * (max_temperature - min_temperature)) - min_temperature


## Represents intensity of the sun light, which peaks at noon.
## Returns value between 0-1, where 1 means the sun is strongest.
func _get_sun_strength() -> float:
	# Noon is represented by point_of_day=0.5.
	# So what we do here is check the "distance" from 0.5 aka noon.
	return 1.0 - absf(clock.point_of_day - 0.5) / 0.5


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
	temperature = _limit_temperature(clock.point_of_day)


func _limit_temperature(temp: float) -> float:
	match clock.season:
		Clock.Season.AUTUMN:
			return clampf(temp, celcius_to_temp(5.0), celcius_to_temp(15.0))
		Clock.Season.WINTER:
			return clampf(temp, celcius_to_temp(-10.0), celcius_to_temp(8.0))
		Clock.Season.SPRING:
			return clampf(temp, celcius_to_temp(10.0), celcius_to_temp(23.0))
		Clock.Season.SUMMER:
			return clampf(temp, celcius_to_temp(12.0), celcius_to_temp(40.0))
	printerr("Unknown season")
	return 0.5
