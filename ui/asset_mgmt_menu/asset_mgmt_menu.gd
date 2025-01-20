class_name AssetMgmtMenu extends PanelContainer

signal enable_action_pressed
signal disable_action_pressed

@onready var enable_button: DrawerBoxButton = %EnableButton
@onready var disable_button: DrawerBoxButton = %DisableButton


func _ready() -> void:
	enable_button.pressed.connect(self.enable_action_pressed.emit)
	disable_button.pressed.connect(self.disable_action_pressed.emit)
