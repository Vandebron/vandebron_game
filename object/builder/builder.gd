extends Node3D
class_name Builder

signal build_done(node: Node3D, at_position: Vector3)

const highlight_material: Material = preload("res://object/builder/highlight_material.tres")
const grid_cell_size := Vector3(1.0, 1.0, 1.0)

@export var building: BuildingDef: set=set_building

# This is so we don't immediately build the building after selecting it from the list
@onready var placement_debounce: Timer = $PlacementDebounce

var placement_model: Model

var _physics_space_state: PhysicsDirectSpaceState3D
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
	
	placement_model.global_position = \
		lerp(placement_model.global_position, _mouse_pos, delta * 15.0)


func confirm() -> void:
	if !_is_ready_for_placement():
		return
	
	_build_confirmed = true
	_build_position = _mouse_pos
	
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
	_hover_tween.tween_property(placement_model, "global_position:y", 0.4, 1.0)
	_hover_tween.tween_property(placement_model, "global_position:y", 0.0, 1.0)
	_hover_tween.set_loops()


func _add_twirl_animation() -> Tween:
	var tween: Tween = create_tween()
	# Rise and twirl
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(placement_model, "global_rotation:y", TAU, 0.4)
	tween.parallel().tween_property(placement_model, "global_position:y", 0.8, 0.4)
	# Fall and bounce
	tween.chain()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.tween_property(placement_model, "global_position:y", 0.0, 0.35)
	return tween


func _add_highlight() -> void:
	for mesh in placement_model.mesh_nodes:
		mesh.material_overlay = highlight_material
		mesh.transparency = 0.5


func _is_ready_for_placement() -> bool:
	return !_build_confirmed && placement_debounce.time_left == 0


func set_building(value: BuildingDef) -> void:
	building = value
	
	# TODO: Can we get this typed as Model in BuildingDef?
	placement_model = building.model.instantiate() as Model
	add_child(placement_model)
	
	call_deferred("_add_hover_animation")
	_add_highlight()
