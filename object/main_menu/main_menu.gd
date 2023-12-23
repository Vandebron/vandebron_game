extends Node3D
class_name MainMenu

signal game_started

@onready var start_game_btn: Button = %StartGameBtn


func _ready() -> void:
	start_game_btn.pressed.connect(_on_game_started)


func _on_game_started() -> void:
	game_started.emit()
