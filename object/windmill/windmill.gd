extends Producer

@export var acceleration: float = 10.0 ## (Cosmetic) Speed at which the blade-spin adjusts to new wind conditions
@export var turn_rate: float = 0.01 ## (Cosmetic) Speed at which the windmill turns toward new wind direction

@onready var model: WindmillModel = $Model
@onready var blades: Node3D = $Model.get_node("Windmill/ControlRoom/Blades")

var _current_speed: float # Between 0-1; cosmetic spin rate of the blades; lerps toward _target_speed
var _target_speed: float # Between 0-1; actual spin rate of the blades
var _wind_angle: float # Just cosmetic
var _wind_amount: float # Determines amount of energy production


func _ready() -> void:
	super()


func _process(delta: float) -> void:
	_current_speed = lerpf(_current_speed, _target_speed, delta * acceleration)
	
	blades.rotate(Vector3.FORWARD, delta * _current_speed)
	model.rotation.y = lerpf(
		model.rotation.y, _wind_angle, delta * turn_rate * _wind_amount)


func get_model() -> Model:
	return model


func _on_disabled() -> void:
	_target_speed = 0.0
	current_power = 0.0


func on_added_to_grid(clock: Clock, weather: Weather) -> void:
	clock.part_of_day_started.connect(self._on_part_of_day_started)


func update_power(_clock: Clock, weather: Weather) -> void:
	if disabled:
		return
	
	_wind_angle = weather.wind_angle
	_wind_amount = weather.wind
	
	_target_speed = clampf(_wind_amount, 0.0, 1.0)
	current_power = _target_speed * nominal_power
	
	if current_power / nominal_power > 0.2:
		model.start_energy_particles()
	else:
		model.stop_energy_particles()


func _on_part_of_day_started(part: Clock.DayPart) -> void:
	if part == Clock.DayPart.DUSK:
		model.animation_player.play("night")
	else:
		model.animation_player.play("day")
