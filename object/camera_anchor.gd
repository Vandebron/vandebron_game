extends Node3D

@export var pan_speed: float = 8.0
@export var snap_speed: float = 5.0

@onready var camera: Camera3D = %Camera3D


func _physics_process(delta: float) -> void:
	var input_raw: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input := Vector3(input_raw.x, 0.0, input_raw.y)
	
	# As soon as we stop giving camera input, snap to the nearest grid cell
	if input.is_zero_approx():
		var snapped_pos: Vector3 = snapped(global_position, Constants.GRID_CELL_SIZE)
		global_position = lerp(global_position, snapped_pos, delta * snap_speed)
		return
	
	global_transform = global_transform\
		.rotated(Vector3.UP, -camera.global_rotation.y)\
		.translated(input * delta * pan_speed)\
		.rotated(Vector3.UP, camera.global_rotation.y)
