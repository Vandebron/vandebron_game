extends Consumer

@onready var model: Model = $Model


func _ready() -> void:
	if Weather.is_day():
		model.animation_player.play("consume")
	
	Events.night_started.connect(func() -> void:
		model.animation_player.play("night"))
	
	Events.night_ended.connect(func() -> void:
		model.animation_player.play("consume"))
