extends Node3D

@export var pan_speed: float = 8.0
@export var snap_speed: float = 5.0
@export var terrain: MeshInstance3D: set=_set_terrain

@onready var camera: Camera3D = $Camera3D

var _bounds: Rect2
var _last_valid_position: Vector3


func _physics_process(delta: float) -> void:
	var input_raw: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input := Vector3(input_raw.x, 0.0, input_raw.y)
	
	# As soon as we stop giving camera input, snap to the nearest grid cell
	if input.is_zero_approx():
		var snapped_pos: Vector3 = global_position.snapped(Constants.GRID_CELL_SIZE)
		global_position = global_position.lerp(snapped_pos, delta * snap_speed)
		return
	
	global_transform = global_transform\
		.rotated(Vector3.UP, -camera.global_rotation.y)\
		.translated(input * delta * pan_speed)\
		.rotated(Vector3.UP, camera.global_rotation.y)
	
	var camera_world_pos: Vector3 = InputUtil.get_cursor_world_position(camera)
	var position_2d = Vector2(camera_world_pos.x, camera_world_pos.z)
	if _bounds.has_point(position_2d):
		_last_valid_position = global_position
	else:
		global_position = _last_valid_position


func _set_terrain(value: MeshInstance3D) -> void:
	terrain = value
	
	var bounds_position := Vector2(
		-(terrain.mesh.size.x / 2.0),
		-(terrain.mesh.size.y / 2.0))
	_bounds = Rect2(bounds_position, terrain.mesh.size)
