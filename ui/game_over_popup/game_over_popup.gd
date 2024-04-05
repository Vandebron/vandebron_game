extends PanelContainer

signal quit_to_menu
signal restart


func _ready() -> void:
	%ReturnToMenuBtn.pressed.connect(func(): quit_to_menu.emit())
	%RestartBtn.pressed.connect(func(): restart.emit())
