extends Node

var _mouse_physics_layer: int


func _ready() -> void:
	_mouse_physics_layer = Utils.get_physics_layer("mouse")


func get_mouse_world_position(physics_space_state: PhysicsDirectSpaceState3D) -> Vector3:
	var mouse_position: Vector2 = Utils.get_actual_viewport().get_mouse_position()
	var camera: Camera3D = Utils.get_camera()
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_target: Vector3 = ray_origin + camera.project_ray_normal(mouse_position) * 2000.0
	
	var raycast_params := PhysicsRayQueryParameters3D.create(ray_origin, ray_target, _mouse_physics_layer)
	raycast_params.collide_with_areas = true
	raycast_params.collide_with_bodies = false
	var intersection: Dictionary = physics_space_state.intersect_ray(raycast_params)
	
	if intersection.is_empty():
		return Vector3()
	return intersection.position
