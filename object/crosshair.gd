extends MeshInstance3D

@export var camera: Camera3D

@onready var crosshair_size: float = mesh.radius * 2.0


func _physics_process(_delta: float) -> void:
	var pointer_pos: Vector3 = InputUtil.get_pointer_world_position(camera)
	global_position = pointer_pos + Vector3(0.0, crosshair_size / 2.0, 0.0)
