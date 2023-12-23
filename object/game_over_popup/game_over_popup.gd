extends PanelContainer

signal quit_to_menu
signal view_map


func _ready() -> void:
	%ReturnToMenuBtn.pressed.connect(func(): quit_to_menu.emit())
