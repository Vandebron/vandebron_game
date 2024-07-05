extends Producer

@onready var model: Model = $Model

signal coal_turned_off
signal coal_turned_on

func _ready() -> void:
	super()
	model.animation_player.play("produce")


func get_model() -> Model:
	return model

func _on_disabled() -> void:
	coal_turned_off.emit()
	current_power = 0.0

func _on_enabled() -> void:
	coal_turned_on.emit()
	current_power = nominal_power
