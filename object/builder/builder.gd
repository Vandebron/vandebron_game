extends Node3D
class_name Builder

@export var building: BuildingDef:
	set(value):
		building = value
		placement_model = building.model.instantiate()
		add_child(placement_model)

var placement_model: Node3D

var _physics_space_state: PhysicsDirectSpaceState3D


func _ready() -> void:
	_physics_space_state = get_world_3d().direct_space_state


func _physics_process(_delta: float) -> void:
	var mouse_pos: Vector3 = InputUtil.get_mouse_world_position(_physics_space_state)
	mouse_pos = snapped(mouse_pos, Vector3(1.0, 1.0, 1.0))
	placement_model.global_position = mouse_pos
