class_name Producer extends EnergyAsset

const DISABLE_ICON_SCN: PackedScene = preload("res://object/producer/disable_icon.tscn")

enum Type {FOSSIL, WIND, SOLAR}

@export var nominal_power: float = 10.0
@export var type: Producer.Type
@export var start_disabled: bool

var disable_icon: Node3D
var current_power: float
var disabled: bool: set=_set_disabled


func _init() -> void:
	add_to_group(Constants.GROUP_PRODUCER)


func _ready() -> void:
	disable_icon = DISABLE_ICON_SCN.instantiate()
	add_child(disable_icon)
	disable_icon.hide()
	
	if start_disabled:
		disabled = true
		current_power = 0.0
	else:
		current_power = nominal_power


func enable() -> void:
	disabled = false


func disable() -> void:
	disabled = true


func _set_disabled(value: bool) -> void:
	disabled = value
	
	if disabled:
		disable_icon.show()
		_on_disabled()
	else:
		disable_icon.hide()
		_on_enabled()


func _on_enabled() -> void:
	pass


func _on_disabled() -> void:
	pass
