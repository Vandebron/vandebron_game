extends Producer

@onready var model: Model = $Model


func _ready() -> void:
	model.animation_player.play("produce")
	current_power = nominal_power
