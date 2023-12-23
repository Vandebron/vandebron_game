extends Node3D

const DEFAULT_GAME: PackedScene = preload("res://world/default_game.tscn")

@onready var game_container: Node3D = $GameContainer
@onready var main_menu_canvas_layer: CanvasLayer = $MainMenuCanvasLayer
@onready var popup_canvas_layer: CanvasLayer = $PopupCanvasLayer
@onready var game_over_popup: PanelContainer = %GameOverPopup
@onready var start_game_btn: Button = %StartGameBtn

var _game: Game


func _ready() -> void:
	start_game_btn.pressed.connect(_load_default_game)
	game_over_popup.quit_to_menu.connect(_quit_to_menu)


func _load_default_game() -> void:
	if _game:
		printerr("Game already loaded")
		get_tree().quit(1)
		return
	
	main_menu_canvas_layer.hide()
	
	_game = DEFAULT_GAME.instantiate()
	_game.game_over.connect(_on_game_over)
	game_container.add_child(_game)


func _quit_to_menu() -> void:
	_game.queue_free()
	_game = null
	popup_canvas_layer.hide()
	game_over_popup.hide()
	main_menu_canvas_layer.show()


func _on_game_over() -> void:
	popup_canvas_layer.show()
	game_over_popup.show()
