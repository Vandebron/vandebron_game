extends Consumer


func _ready() -> void:
	model.animation_player.play("consume")
	
	Events.night_started.connect(func() -> void:
		model.animation_player.play("night"))
	
	Events.night_ended.connect(func() -> void:
		model.animation_player.play("consume"))
