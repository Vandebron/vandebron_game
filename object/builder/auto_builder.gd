class_name AutoBuilder extends Builder


func _process(_delta: float) -> void:
	pass


func _find_non_excluded_position(center: Vector3, attempt: int, excluded_positions: Array) -> Vector3:
	var position_offset: Vector3
	var potential_position: Vector3
	var found: bool = false

	while not found:
		position_offset = Vector3(
			randi_range(-attempt, attempt),
			0,
			randi_range(-attempt, attempt)
		)
		potential_position = center + position_offset
		potential_position = potential_position.snapped(Vector3.ONE)
		if not excluded_positions.has(potential_position):
			found = true
			return potential_position
		attempt += 1
	return Vector3.ZERO

	
func plot_building(center: Vector3, excluded_positions: Array[Vector3], shape_cast: ShapeCast3D, attempt := 0) -> void:
	shape_cast.global_transform.origin = _find_non_excluded_position(center, attempt, excluded_positions)
	shape_cast.target_position = Vector3.ZERO
	shape_cast.force_shapecast_update()

	if not shape_cast.is_colliding():
		_build_position = shape_cast.global_position
		print_verbose("Suitable position found at: ", shape_cast.global_position)
		confirm()  # Implement this to handle successful placement
	else:
		print_verbose("No suitable position found at: ", shape_cast.global_position)
		var next_attempt = attempt + 1
		plot_building(center, excluded_positions, shape_cast, next_attempt)


func _can_place() -> bool:
	return true


func confirm() -> void:
	_shape.hide()
	
	var twirl_tween: Tween = _add_twirl_animation()
	twirl_tween.tween_callback(self._done)
