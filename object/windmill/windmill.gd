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


func _input(event: InputEvent) -> void:
	if event.is_action_released("show_info"):
		hide_info()


func _physics_process(delta: float) -> void:
	_speed = lerpf(_speed, _target_speed, delta * acceleration)
	active_capability_out = _target_speed * nominal_power
	current_power = clampf(_speed * active_capability_out, dmol, nominal_power)


func _process(delta: float) -> void:
	model.animation_player.speed_scale = _speed
	model.global_rotation.y = lerpf(
		model.global_rotation.y, weather.wind_angle, delta * turn_rate * weather.wind)
	
	#if Input.is_action_pressed("show_info"):
		#show_info()


#func show_info() -> void:
	#%ProductionGaugeCtnr.visible = true
	#%ProductionGaugeCtnr.global_position = Utils.get_camera().unproject_position(global_position)
	#%ProductionGaugeCtnr.position -= %ProductionGaugeCtnr.size / 2.0 # Center it based on its size
	#%ProductionGaugeCtnr.position.y -= 40.0 # Nudge it up a little
	#
	#%ProductionGauge.current = _speed
	#%ProductionGauge.target = _target_speed
	#%ProductionGauge.max_value = 1.0
	#
	#%kwLbl.text = str(current_power).pad_decimals(1) + "kW"


func hide_info() -> void:
	%ProductionGaugeCtnr.visible = false


func _on_disabled() -> void:
	_target_speed = 0.0


func _update_target_speed() -> void:
	if disabled:
		return
	
	_target_speed = clampf(weather.wind - _variance, 0.0, 1.0)


## Introduces some randomness to production, so every windmill is a little bit different.
func _update_variance() -> void:
	_variance = randf() * production_variance
