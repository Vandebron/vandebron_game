class_name DrawerBoxButton extends PanelContainer

signal pressed

@export var icon: Texture2D: set=set_icon


func _ready() -> void:
	_update_ui()


func set_icon(value: Texture2D) -> void:
	icon = value
	_update_ui()


func _update_ui() -> void:
	var button: TextureButton = $IconButton
	button.texture_normal = icon
	if !button.pressed.is_connected(self.pressed.emit):
		button.pressed.connect(self.pressed.emit)
