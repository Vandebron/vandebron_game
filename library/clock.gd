class_name Clock extends Node

signal part_of_day_started(part: Clock.DayPart)
signal part_of_day_ended(part: Clock.DayPart)
signal season_started(season: Clock.Season)
signal season_ended(season: Clock.Season)

enum Season {SUMMER, AUTUMN, WINTER, SPRING}
enum DayPart {DAWN, NOON, DUSK, NIGHT}

@export var days_per_season: int = 1
# Cycle of 30 seconds means day=15s, night=15s
@export var day_night_cycle_ms: int = 5_000
# Start the game at 6 'o clock
@export var game_start_offset_ms: int = floori((6.0 / 24.0) * float(day_night_cycle_ms))

# Ranges from 0-1; 0=night, 0.25=dawn, 0.5=noon, 0.75=dusk
var point_of_day: float = 1.0
# Ranges from 0-24
var time_of_day: float = 0.0: get=_get_time_of_day
var part_of_day: DayPart = DayPart.NOON: get=_get_part_of_day
var season: Season

var _days_passed: int
var _prev_part_of_day: DayPart = DayPart.DAWN

var current_tick_ms: int


func _physics_process(_delta: float) -> void:
	point_of_day = _get_point_of_day() # This gets sampled so much, so we cache it here
	_handle_day_transitions()


func _process(delta: float) -> void:
	current_tick_ms += int(delta * 1000.0)


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


## Returns value in 0-24h range for a given point in the future
func get_part_of_day_plus(offset_time_ms: int) -> float:
	var t: float = _get_cycle_value(int(day_night_cycle_ms), game_start_offset_ms + offset_time_ms)
	var point_of_day_in_future = (1.0 - t) / 2.0
	return point_of_day_in_future * 24.0


func _get_cycle_value(cycle_time_ms: int, offset: int = 0) -> float:
	var current_time_ms: int = current_tick_ms + offset
	return 1.0 - (2.0 * (current_time_ms % cycle_time_ms)) / cycle_time_ms


## Returns value in 0-1 range.
func _get_point_of_day() -> float:
	var t: float = _get_cycle_value(int(day_night_cycle_ms), game_start_offset_ms)
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


func _handle_day_transitions() -> void:
	if part_of_day == _prev_part_of_day:
		return
	
	part_of_day_ended.emit(_prev_part_of_day)
	part_of_day_started.emit(part_of_day)
	_prev_part_of_day = part_of_day
	
	if part_of_day != DayPart.DAWN:
		return
	
	_days_passed += 1
	
	if _days_passed % days_per_season > 0:
		return
	
	# Increment season every X days, and make sure it wraps around from summer to autumn.
	season_ended.emit(season)
	season = wrapi(season + 1, 0, Season.size()) as Season
	season_started.emit(season)
