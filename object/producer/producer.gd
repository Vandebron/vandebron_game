extends EnergyAsset
class_name Producer

const disable_icon_scn: PackedScene = preload("res://object/producer/disable_icon.tscn")

enum Type {FOSSIL, WIND, SOLAR}

@export var nominal_power: float = 10.0
@export var active_capability_out: float
@export var dmol: float = 0.0
@export var type: Producer.Type
@export var clock: Clock
@export var weather: Weather

var disable_icon: Node3D
var current_power: float = 0.0
var disabled: bool: set=_set_disabled


func _init() -> void:
	add_to_group(Constants.GROUP_PRODUCER)


func _ready() -> void:
	current_power = nominal_power
	
	disable_icon = disable_icon_scn.instantiate()
	add_child(disable_icon)
	disable_icon.hide()


func enable() -> void:
	disabled = false


func disable() -> void:
	disabled = true


func _on_enabled() -> void:
	pass


func _on_disabled() -> void:
	pass


func _set_disabled(value: bool) -> void:
	disabled = value
	
	if disabled:
		disable_icon.show()
		_on_disabled()
	else:
		disable_icon.hide()
		_on_enabled()


func on_added_to_grid() -> void:
	pass
