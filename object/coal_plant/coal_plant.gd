extends Producer

@onready var model: Model = $Model

func _ready() -> void:
	super()
	model.animation_player.play("produce")


func get_model() -> Model:
	return model


func _on_disabled() -> void:
	current_power = 0.0


func _on_enabled() -> void:
	current_power = nominal_power
