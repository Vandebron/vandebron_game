extends Producer

@export var production_variance: float = 0.05
@export var acceleration: float = 10.0 # Determines how fast windmill adjusts to new wind speeds
@export var turn_rate: float = 0.01 # Just cosmetic

@onready var variance_timer: Timer = $VarianceTimer
@onready var model: Model = $Model

var _speed: float = 1.0
var _target_speed: float = 1.0
var _variance: float = 0.1 # Represents random production deviation per windmill


func _ready() -> void:
	model.animation_player.play("spin")
	variance_timer.timeout.connect(self._update_variance)


func _input(event: InputEvent) -> void:
	if event.is_action_released("show_info"):
		hide_info()


func _physics_process(delta: float) -> void:
	_target_speed = clampf(Weather.wind - _variance, 0.0, 1.0)
	_speed = lerpf(_speed, _target_speed, delta * acceleration)
	active_capability_out = _target_speed * nominal_power
	current_power = clampf(_speed * active_capability_out, dmol, nominal_power)
	
	model.animation_player.speed_scale = _speed
	model.global_rotation.y = lerpf(
		model.global_rotation.y, Weather.wind_angle, delta * turn_rate * Weather.wind)
	
	if Input.is_action_pressed("show_info"):
		show_info()


func _update_variance() -> void:
	_variance = randf() * production_variance


func show_info() -> void:
	$ProductionGaugeCtnr.visible = true
	$ProductionGaugeCtnr.global_position = Utils.get_camera().unproject_position(global_position)
	%ProductionGauge.material.set_shader_parameter("current", _speed)
	%ProductionGauge.material.set_shader_parameter("target", _target_speed)


func hide_info() -> void:
	$ProductionGaugeCtnr.visible = false
	%ProductionGauge.material.set_shader_parameter("current", _target_speed)
