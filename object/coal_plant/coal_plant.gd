extends Producer

@onready var model: Model = $Model

var _target_power: float = 0.0


func _ready() -> void:
	super()
	model.animation_player.play("produce")
	_target_power = nominal_power
	current_power = nominal_power


func _process(delta: float) -> void:
	current_power = lerpf(current_power, _target_power, delta * 0.1)


func get_model() -> Model:
	return model


func _on_disabled() -> void:
	_target_power = 0.0


func _on_enabled() -> void:
	_target_power = nominal_power
