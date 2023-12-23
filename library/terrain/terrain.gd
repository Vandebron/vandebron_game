extends MeshInstance3D

@export var camera: Camera3D

@onready var grid_material: ShaderMaterial = get_surface_override_material(0).next_pass as ShaderMaterial


func _physics_process(_delta: float) -> void:
	var pointer_world_pos: Vector3 = InputUtil.get_pointer_world_position(camera)
	grid_material.set_shader_parameter("pointer_world_pos", pointer_world_pos)
