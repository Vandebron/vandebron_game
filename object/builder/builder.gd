extends Node3D
class_name Builder

signal build_done(node: Node3D, building: BuildingDef, at_position: Vector3)

@export var building: BuildingDef: set=set_building

# This is so we don't immediately build the building after selecting it from the list
@onready var placement_debounce: Timer = $PlacementDebounce

var _model: Model
var _shape: BuildShapeIndicator
var _collider: Area3D
var _terrain_collider: Area3D
var _build_confirmed: bool
var _build_position: Vector3
var _pointer_pos: Vector3
var _hover_tween: Tween
var _camera: Camera3D


func _init() -> void:
	add_to_group(Constants.GROUP_BUILDER)


func _ready() -> void:
	_camera = get_viewport().get_camera_3d()


func _process(delta: float) -> void:
	if _build_confirmed:
		return
	
	_pointer_pos = InputUtil.get_pointer_world_position(_camera).snapped(Constants.GRID_CELL_SIZE)
	
	_model.global_position = _model.global_position.lerp(_pointer_pos, delta * 15.0)
	_shape.global_position = _shape.global_position.lerp(_pointer_pos, delta * 15.0)
	_collider.global_position = _pointer_pos
	_terrain_collider.global_position = _pointer_pos
	
	if _can_place():
		_shape.set_good()
	else:
		_shape.set_bad()


func confirm() -> void:
	if !_can_place():
		print("cant")
		return
	
	_build_confirmed = true
	_build_position = _pointer_pos
	
	_shape.hide()
	
	_hover_tween.kill()
	var twirl_tween: Tween = _add_twirl_animation()
	twirl_tween.tween_callback(self._done)
	
func auto_confirm(house_positions: Array[Consumer], producer_positions: Array[Producer], battery_positions: Array[Battery]) -> void:
	var all_building_positions = house_positions + producer_positions + battery_positions
	# Start by checking if there are any houses to place near
	if house_positions.is_empty():
		print("No houses to place near.")
		return

	var valid_position_found = false
	var attempts = 0
	var max_attempts = house_positions.size()  # Avoid infinite loops

	while !valid_position_found and attempts < max_attempts:
		# Randomly select a house
		var base_house = house_positions[randi() % house_positions.size()]
		var base_position = base_house.global_position  # Assuming global_position holds the position

		# Define potential adjacent positions
		var adjacent_positions = [
			base_position + Constants.GRID_CELL_SIZE * Vector3(1, 0, 0),  # East
			base_position + Constants.GRID_CELL_SIZE * Vector3(-1, 0, 0),  # West
			base_position + Constants.GRID_CELL_SIZE * Vector3(0, 0, 1),  # North
			base_position + Constants.GRID_CELL_SIZE * Vector3(0, 0, -1)   # South
		]

		# Check each adjacent position for occupancy
		for position in adjacent_positions:
			_pointer_pos = position  # Temporarily set pointer position for _can_place check
			if _can_place():  # Use existing logic to check if the position is buildable
				_build_position = position
				valid_position_found = true
				break

		attempts += 1

	if not valid_position_found:
		print("Couldn't find a valid position near a house.")
		return

	_build_confirmed = true
	print("_build_position")
	print(_build_position)

	_shape.hide()

	_hover_tween.kill()
	var twirl_tween: Tween = _add_twirl_animation()
	print("twirl tween")
	#twirl_tween.tween_callback(self._done)
	_done()  # Proceed with placement


func cancel() -> void:
	if _build_confirmed:
		return # Too late to cancel now, as the build placement is already confirmed
	
	queue_free()


func _done() -> void:
	var node: Node3D = building.scene.instantiate()
	build_done.emit(node, building, _build_position)
	
	queue_free()


func _add_hover_animation() -> void:
	_hover_tween = create_tween()
	# Bob up and down
	_hover_tween.set_ease(Tween.EASE_IN_OUT)
	_hover_tween.set_trans(Tween.TRANS_SINE)
	_hover_tween.tween_property(_model, "global_position:y", 0.4, 1.0)
	_hover_tween.tween_property(_model, "global_position:y", 0.0, 1.0)
	_hover_tween.set_loops()


func _add_twirl_animation() -> Tween:
	var tween: Tween = create_tween()
	# Rise and twirl
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(_model, "global_rotation:y", TAU, 0.4)
	tween.parallel().tween_property(_model, "global_position:x", _build_position.x, 0.4)
	tween.parallel().tween_property(_model, "global_position:z", _build_position.z, 0.4)
	tween.parallel().tween_property(_model, "global_position:y", 0.8, 0.4)
	# Fall and bounce
	tween.chain()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.tween_property(_model, "global_position:y", 0.0, 0.35)
	return tween


func _can_place() -> bool:
	return !_build_confirmed\
		&& placement_debounce.time_left == 0\
		&& !_collider.has_overlapping_areas()\
		&& _terrain_collider.has_overlapping_areas() # i.e. don't be out-of-bounds


func set_building(value: BuildingDef) -> void:
	building = value
	
	# TODO: Can we get this typed as Model in BuildingDef?
	_model = building.model.instantiate() as Model
	add_child(_model)
	
	_collider = building.collider.instantiate()
	add_child(_collider)
	
	_terrain_collider = building.collider.instantiate()
	_terrain_collider.collision_layer = 0
	_terrain_collider.collision_mask = Utils.get_physics_layer("terrain")
	add_child(_terrain_collider)
	
	_shape = building.shape.instantiate() as BuildShapeIndicator
	_shape.ignore_visibility = true
	_shape.collider = _collider
	add_child(_shape)
	
	call_deferred("_add_hover_animation")
