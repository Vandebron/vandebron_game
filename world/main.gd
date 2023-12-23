extends Node3D

const DEFAULT_GAME: PackedScene = preload("res://world/default_game.tscn")
const MAIN_MENU: PackedScene = preload("res://object/main_menu/main_menu.tscn")

@onready var game_container: Node3D = $GameContainer
@onready var main_menu_container: Node3D = $MainMenuContainer
@onready var popup_canvas_layer: CanvasLayer = $PopupCanvasLayer
@onready var game_over_popup: PanelContainer = %GameOverPopup

var _game: Game
var _main_menu: MainMenu: set=_set_main_menu


func _ready() -> void:
	_main_menu = $MainMenuContainer/MainMenu
	game_over_popup.quit_to_menu.connect(_quit_to_menu)


func _load_default_game() -> void:
	if _game:
		printerr("Game already loaded")
		get_tree().quit(1)
		return
	
	_main_menu.queue_free()
	
	_game = DEFAULT_GAME.instantiate()
	_game.game_over.connect(_on_game_over)
	game_container.add_child(_game)


func _quit_to_menu() -> void:
	_game.queue_free()
	_game = null
	
	_main_menu = MAIN_MENU.instantiate()
	main_menu_container.add_child(_main_menu)
	
	popup_canvas_layer.hide()
	game_over_popup.hide()


func _on_game_over() -> void:
	popup_canvas_layer.show()
	game_over_popup.show()


func _set_main_menu(value: MainMenu) -> void:
	_main_menu = value
	_main_menu.game_started.connect(_load_default_game)
