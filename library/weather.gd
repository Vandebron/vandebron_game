extends Node
class_name Weather

enum Season {AUTUMN, WINTER, SPRING, SUMMER}
enum DayPart {DAWN, NOON, DUSK, NIGHT}

const days_per_season: int = 7
const day_night_cycle_ms: int = 30_000 # Cycle of 30 seconds means day=15s, night=15s
const game_start_offset_ms: int = floori((6.0 / 24.0) * float(day_night_cycle_ms)) # Start the game at 6 'o clock
const wind_cycle_ms: int = 30_000 # Dictates how long it takes for weather to repeat
const min_temperature: float = -10.0
const max_temperature: float = 40.0

var wind_angle: float = 1.0 # Direction of wind in radians. Cosmetic. does not affect wind power
var wind: float = 0.5 # Ranges from 0-1
var sun: float = 0.5 # Ranges from 0-1
var sun_strength: float: get=_get_sun_strength # Ranges from 0-1
var temperature: float = 0.0 # Ranges from 0-1; let's say 0=-10, 1=40
var point_of_day: float = 1.0 # Ranges from 0-1; 0=night, 0.25=dawn, 0.5=noon, 0.75=dusk
var time_of_day: float = 0.0: get=_get_time_of_day # Ranges from 0-24
var part_of_day: DayPart = DayPart.DAWN: get=_get_part_of_day
var season: Season

var _target_wind: float = 1.0
var _days_passed: int
var _prev_part_of_day: DayPart = DayPart.DAWN


func _ready() -> void:
	_update_wind()
	_update_temperature()


func _physics_process(delta: float) -> void:
	point_of_day = _get_point_of_day() # This gets sampled so much, so we cache it here
	_handle_day_transitions()
	wind = lerpf(wind, _target_wind, delta)


func celcius_to_temp(celcius: float) -> float:
	return (celcius + min_temperature) / (max_temperature - min_temperature)


func temp_to_celcius(temp: float) -> float:
	return (temp * (max_temperature - min_temperature)) - min_temperature


func is_dawn() -> bool:
	return part_of_day == DayPart.DAWN


func is_noon() -> bool:
	return part_of_day == DayPart.NOON


func is_dusk() -> bool:
	return part_of_day == DayPart.NOON


func is_night() -> bool:
	return part_of_day == DayPart.NIGHT


func is_day() -> bool:
	return !is_night()


## Returns value in 0-24h range
func _get_time_of_day() -> float:
	return point_of_day * 24.0


## Returns value in 0-1 range.
func _get_point_of_day() -> float:
	var t: float = Utils.get_cycle_value(int(day_night_cycle_ms), game_start_offset_ms)
	return (1.0 - t) / 2.0


func _get_part_of_day() -> DayPart:
	var time: float = time_of_day
	if time > 6.00 && time <= 12.00:
		return DayPart.DAWN
	if time > 12.00 && time <= 18.00:
		return DayPart.NOON
	if time > 18.00 && time <= 24.00:
		return DayPart.DUSK
	return DayPart.NIGHT


## Represents intensity of the sun light, which peaks at noon.
## Returns value between 0-1, where 1 means the sun is strongest.
func _get_sun_strength() -> float:
	# Noon is represented by point_of_day=0.5.
	# So what we do here is check the "distance" from 0.5 aka noon.
	return 1.0 - abs(point_of_day - 0.5) / 0.5


func _handle_day_transitions() -> void:
	if part_of_day == _prev_part_of_day:
		return
	
	Events.part_of_day_ended.emit(_prev_part_of_day)
	Events.part_of_day_started.emit(part_of_day)
	_prev_part_of_day = part_of_day
	
	if part_of_day != DayPart.DAWN:
		return
	
	_days_passed += 1
	
	if _days_passed % days_per_season > 0:
		return
	
	# Increment season every X days, and make sure it wraps around from summer to autumn.
	Events.season_ended.emit(season)
	season = wrapi(season + 1, 0, Season.size()) as Season
	Events.season_started.emit(season)


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
	match season:
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
