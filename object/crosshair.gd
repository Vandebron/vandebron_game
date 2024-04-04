extends MeshInstance3D

@onready var crosshair_size: float = mesh.radius * 2.0

var _camera: Camera3D


func _ready() -> void:
	_camera = get_viewport().get_camera_3d()


func _process(_delta: float) -> void:
	var pointer_pos: Vector3 = InputUtil.get_pointer_world_position(_camera)
	global_position = pointer_pos + Vector3(0.0, crosshair_size / 2.0, 0.0)
