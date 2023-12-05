extends Node3D
class_name Producer

@export var nominal_power: float = 10.0
@export var active_capability_out: float
@export var dmol: float = 0.0

var current_power: float


func _init() -> void:
	add_to_group(Constants.GROUP_PRODUCER)


func _ready() -> void:
	current_power = nominal_power
