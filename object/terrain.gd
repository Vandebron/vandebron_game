extends MeshInstance3D

# TODO: Crosshair should probably be on CameraAnchor, but I'm lazy
@onready var crosshair: MeshInstance3D = %Crosshair

var _physics_space_state: PhysicsDirectSpaceState3D

var grid_material: ShaderMaterial


func _ready() -> void:
	_physics_space_state = get_world_3d().direct_space_state
	grid_material = get_surface_override_material(0).next_pass as ShaderMaterial
	grid_material.set_shader_parameter("cell_size", Constants.GRID_CELL_SIZE.x)


func _process(_delta: float) -> void:
	var pointer_pos: Vector3 = InputUtil.get_pointer_world_position(_physics_space_state)
	grid_material.set_shader_parameter("pointer_world_pos", pointer_pos)
	crosshair.global_position = pointer_pos
