extends MeshInstance3D

var _physics_space_state: PhysicsDirectSpaceState3D

var grid_material: ShaderMaterial


func _ready() -> void:
	_physics_space_state = get_world_3d().direct_space_state
	grid_material = get_surface_override_material(0).next_pass as ShaderMaterial


func _process(_delta: float) -> void:
	var mouse_pos: Vector3 = InputUtil.get_mouse_world_position(_physics_space_state)
	grid_material.set_shader_parameter("mouse_world_pos", mouse_pos)
