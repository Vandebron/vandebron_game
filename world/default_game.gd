extends Game

@onready var health_manager: HealthManager = %HealthManager


func _ready() -> void:
	health_manager.health_zeroed.connect(_on_game_over)


func _on_game_over() -> void:
	game_over.emit()
