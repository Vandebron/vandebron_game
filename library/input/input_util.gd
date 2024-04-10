extends Node3D

enum DeviceType {MOUSE_KEYBOARD, CONTROLLER}

var _device_type: DeviceType # TODO: Detect input device
var _mouse_physics_layer: int
var _pointer_world_pos: Vector3
var _pointer_world_pos_last_updated: int
var _physics_space_state: PhysicsDirectSpaceState3D


func _ready() -> void:
	_mouse_physics_layer = Utils.get_physics_layer("mouse")
	_physics_space_state = get_world_3d().direct_space_state
	
	if Input.get_connected_joypads().size() > 0:
		_device_type = DeviceType.CONTROLLER
	else:
		_device_type = DeviceType.MOUSE_KEYBOARD


func _input(event: InputEvent) -> void:
	if event is InputEventKey || event is InputEventMouseButton:
		_device_type = DeviceType.MOUSE_KEYBOARD
	elif event is InputEventJoypadButton:
		_device_type = DeviceType.CONTROLLER


func get_pointer_world_position(camera: Camera3D) -> Vector3:
	if _pointer_world_pos_last_updated == Time.get_ticks_msec():
		return _pointer_world_pos
	
	match _device_type:
		DeviceType.MOUSE_KEYBOARD:
			_pointer_world_pos = get_mouse_world_position(camera)
		_:
			_pointer_world_pos = get_cursor_world_position(camera)
	
	_pointer_world_pos_last_updated = Time.get_ticks_msec()
	return _pointer_world_pos


func get_mouse_world_position(camera: Camera3D) -> Vector3:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_target: Vector3 = ray_origin + camera.project_ray_normal(mouse_position) * 2000.0
	return _raycast_for_pointer_position(ray_origin, ray_target)


func get_cursor_world_position(camera: Camera3D) -> Vector3:
	var ray_origin: Vector3 = camera.global_transform.origin
	var ray_direction: Vector3 = -camera.global_transform.basis.z.normalized()
	var ray_target: Vector3 = ray_origin + ray_direction * 1000.0
	return _raycast_for_pointer_position(ray_origin, ray_target)


func _raycast_for_pointer_position(ray_origin: Vector3, ray_target: Vector3) -> Vector3:
	var raycast_params := PhysicsRayQueryParameters3D.create(ray_origin, ray_target, _mouse_physics_layer)
	raycast_params.collide_with_areas = true
	raycast_params.collide_with_bodies = false
	var intersection: Dictionary = _physics_space_state.intersect_ray(raycast_params)
	
	if intersection.is_empty():
		return Vector3()
	return intersection.position
