extends Node3D
class_name Producer

enum Type {FOSSIL, WIND, SOLAR}

@export var nominal_power: float = 10.0
@export var active_capability_out: float
@export var dmol: float = 0.0
@export var type: Producer.Type
@export var weather: Weather

var current_power: float = 0.0


func _init() -> void:
	add_to_group(Constants.GROUP_PRODUCER)


func _ready() -> void:
	current_power = nominal_power


func on_added_to_grid() -> void:
	pass
