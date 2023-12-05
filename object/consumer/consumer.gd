extends Node3D
class_name Consumer

@export var demand: float


func _init() -> void:
	add_to_group(Constants.GROUP_CONSUMER)
