extends PanelContainer
class_name MessageDialog

signal dismissed

enum Type {INFO, WARNING}

@export var title: String = "Lorem":
	set(value):
		title = value
		%Title.text = title

@export var description: String = "Ipsum":
	set(value):
		description = value
		%Description.text = description

@export var type: Type = Type.INFO:
	set(value):
		type = value
		match type:
			Type.INFO:
				%TitlePanelCtnr.set_type_variation = "info"
			Type.WARNING:
				%TitlePanelCtnr.set_type_variation = "warning"

@export var timeout: float = 10.0: set=_set_timeout

@onready var dismiss_btn: Button = %DismissBtn
@onready var timer: Timer = %Timer


func _ready() -> void:
	dismiss_btn.pressed.connect(dismiss)
	timer.timeout.connect(dismiss)
	
	_set_timeout(timeout)


func _process(_delta: float) -> void:
	%TimeoutBar.value = timer.time_left


func dismiss() -> void:
	dismissed.emit()
	queue_free()


func _set_timeout(value: float) -> void:
	timeout = value
	%Timer.wait_time = timeout
	%TimeoutBar.max_value = timeout
	%TimeoutBar.value = %TimeoutBar.max_value
