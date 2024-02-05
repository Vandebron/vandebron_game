extends Producer

@export var production_variance: float = 0.05 # Deviation from production
@export var acceleration: float = 10.0 # Determines how fast windmill adjusts to new wind speeds
@export var turn_rate: float = 0.01 # Just cosmetic

@onready var update_timer: Timer = $UpdateTimer
@onready var variance_timer: Timer = $VarianceTimer
@onready var model: Model = $Model

var _speed: float = 0.0
var _target_speed: float = 0.0
var _variance: float = 0.1 # Represents random production deviation per windmill


func _ready() -> void:
	super()
	model.animation_player.play("spin")
	update_timer.timeout.connect(_update_target_speed)
	variance_timer.timeout.connect(_update_variance)


func _process(delta: float) -> void:
	model.animation_player.speed_scale = _speed
	model.global_rotation.y = lerpf(
		model.global_rotation.y, weather.wind_angle, delta * turn_rate * weather.wind)
	
	_speed = lerpf(_speed, _target_speed, delta * acceleration)
	active_capability_out = _target_speed * nominal_power
	current_power = clampf(_speed * active_capability_out, dmol, nominal_power)


func _on_disabled() -> void:
	_target_speed = 0.0
	
func on_added_to_grid() -> void:
	clock.part_of_day_started.connect(self._on_part_of_day_started)

func _update_target_speed() -> void:
	if disabled:
		return
	
	_target_speed = clampf(weather.wind - _variance, 0.0, 1.0)


## Introduces some randomness to production, so every windmill is a little bit different.
func _update_variance() -> void:
	_variance = randf() * production_variance

func _on_part_of_day_started(part: Clock.DayPart) -> void:
	if part == Clock.DayPart.DUSK:
		model.animation_player.play("night")
	else:
		model.animation_player.play("day")
