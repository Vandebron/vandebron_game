extends Node3D

@export var camera_speed: float = 10.0

@onready var camera_anchor: Node3D = %CameraAnchor
@onready var camera: Camera3D = %Camera3D


func _physics_process(delta: float) -> void:
	var input_raw: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input := Vector3(input_raw.x, 0.0, input_raw.y)

	camera_anchor.global_transform = camera_anchor.global_transform\
		.rotated(Vector3.UP, -camera.global_rotation.y)\
		.translated(input * delta * camera_speed)\
		.rotated(Vector3.UP, camera.global_rotation.y)
