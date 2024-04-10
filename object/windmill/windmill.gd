extends Producer

@export var acceleration: float = 10.0 # Determines how fast windmill adjusts to new wind speeds
@export var turn_rate: float = 0.01 # Just cosmetic

@onready var update_timer: Timer = $UpdateTimer
@onready var variance_timer: Timer = $VarianceTimer
@onready var model: Model = $Model
@onready var blades: Node3D = $Model.get_node("Windmill/ControlRoom/Blades")

var _speed: float = 0.0
var _target_speed: float = 0.0


func _ready() -> void:
	super()
	update_timer.timeout.connect(_update_target_speed)


func _process(delta: float) -> void:
	blades.rotate(Vector3.FORWARD, delta * _speed)
	model.rotation.y = lerpf(
		model.rotation.y, weather.wind_angle, delta * turn_rate * weather.wind)
	
	_speed = lerpf(_speed, _target_speed, delta * acceleration)
	active_capability_out = _target_speed * nominal_power
	current_power = clampf(_speed * active_capability_out, dmol, nominal_power)


func get_model() -> Model:
	return model


func _on_disabled() -> void:
	_target_speed = 0.0


func on_added_to_grid() -> void:
	clock.part_of_day_started.connect(self._on_part_of_day_started)


func _update_target_speed() -> void:
	if disabled:
		return
	
	_target_speed = clampf(weather.wind, 0.0, 1.0)


func _on_part_of_day_started(part: Clock.DayPart) -> void:
	if part == Clock.DayPart.DUSK:
		model.animation_player.play("night")
	else:
		model.animation_player.play("day")
