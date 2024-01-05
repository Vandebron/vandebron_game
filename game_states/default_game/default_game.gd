extends Game

@onready var health_manager: HealthManager = %HealthManager


func _ready() -> void:
	get_tree().paused = false
	health_manager.health_zeroed.connect(_on_game_over)


func _on_game_over() -> void:
	get_tree().paused = true
	game_over.emit()
