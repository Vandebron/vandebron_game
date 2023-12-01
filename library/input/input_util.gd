extends Node

enum DeviceType {MOUSE_KEYBOARD, CONTROLLER}

var _device_type: DeviceType # TODO: Detect input device
var _mouse_physics_layer: int


func _ready() -> void:
	_mouse_physics_layer = Utils.get_physics_layer("mouse")
	
	#_device_type = DeviceType.CONTROLLER # Turn on to debug non-pc input


func get_pointer_world_position(physics_space_state: PhysicsDirectSpaceState3D) -> Vector3:
	match _device_type:
		DeviceType.MOUSE_KEYBOARD:
			return get_mouse_world_position(physics_space_state)
		_:
			return get_cursor_world_position(physics_space_state)


func get_mouse_world_position(physics_space_state: PhysicsDirectSpaceState3D) -> Vector3:
	var mouse_position: Vector2 = Utils.get_actual_viewport().get_mouse_position()
	var camera: Camera3D = Utils.get_camera()
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_target: Vector3 = ray_origin + camera.project_ray_normal(mouse_position) * 2000.0
	return _raycast_for_pointer_position(ray_origin, ray_target, physics_space_state)


func get_cursor_world_position(physics_space_state: PhysicsDirectSpaceState3D) -> Vector3:
	var camera: Camera3D = Utils.get_camera()
	var ray_origin: Vector3 = camera.global_transform.origin
	var ray_direction: Vector3 = -camera.global_transform.basis.z.normalized()
	var ray_target: Vector3 = ray_origin + ray_direction * 1000.0
	return _raycast_for_pointer_position(ray_origin, ray_target, physics_space_state)


func _raycast_for_pointer_position(
	ray_origin: Vector3,
	ray_target: Vector3,
	physics_space_state: PhysicsDirectSpaceState3D
) -> Vector3:
	var raycast_params := PhysicsRayQueryParameters3D.create(ray_origin, ray_target, _mouse_physics_layer)
	raycast_params.collide_with_areas = true
	raycast_params.collide_with_bodies = false
	var intersection: Dictionary = physics_space_state.intersect_ray(raycast_params)
	
	if intersection.is_empty():
		return Vector3()
	return intersection.position
