extends Node3D
class_name Builder

signal build_done(node: Node3D, at_position: Vector3)

const grid_cell_size := Vector3(1.0, 1.0, 1.0)
var good_placement_color := Color.hex(0x8ab060ff)
var bad_placement_color := Color.hex(0xb45252ff)

@export var building: BuildingDef: set=set_building

# This is so we don't immediately build the building after selecting it from the list
@onready var placement_debounce: Timer = $PlacementDebounce

var _highlight_material: Material = preload("res://object/builder/highlight_material.tres")
var _physics_space_state: PhysicsDirectSpaceState3D
var _model: Model
var _shape: Model
var _collider: Area3D
var _build_confirmed: bool
var _build_position: Vector3
var _mouse_pos: Vector3
var _hover_tween: Tween


func _ready() -> void:
	_physics_space_state = get_world_3d().direct_space_state


func _physics_process(delta: float) -> void:
	if _build_confirmed:
		return
	
	_mouse_pos = InputUtil.get_mouse_world_position(_physics_space_state)
	_mouse_pos = snapped(_mouse_pos, grid_cell_size)
	
	global_position = lerp(global_position, _mouse_pos, delta * 15.0)
	
	_highlight_material.albedo_color =\
		bad_placement_color if _collider.has_overlapping_areas() else good_placement_color


func confirm() -> void:
	if !_can_place():
		return
	
	_build_confirmed = true
	_build_position = _mouse_pos
	
	_shape.hide()
	
	_hover_tween.kill()
	var twirl_tween: Tween = _add_twirl_animation()
	twirl_tween.tween_callback(self._done)


func cancel() -> void:
	if _build_confirmed:
		return # Too late to cancel now, as the build placement is already confirmed
	
	queue_free()


func _done() -> void:
	var node: Node3D = building.scene.instantiate()
	build_done.emit(node, _build_position)
	
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
		&& !_collider.has_overlapping_areas()


func set_building(value: BuildingDef) -> void:
	building = value
	
	# TODO: Can we get this typed as Model in BuildingDef?
	_model = building.model.instantiate() as Model
	add_child(_model)
	_shape = building.shape.instantiate() as Model
	add_child(_shape)
	_collider = building.collider.instantiate()
	add_child(_collider)
	
	call_deferred("_add_hover_animation")
