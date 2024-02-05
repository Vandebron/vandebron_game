extends Node3D
class_name BuildManager

@export var energy_grid: EnergyGrid
@export var build_menu: BuildMenu: set=_set_build_menu
@export var buildings: Array[BuildingDef] = []: set=_set_buildings


func _ready() -> void:
	Events.curtailer_initiated.connect(_cancel_all)


func _input(event: InputEvent) -> void:
	if event.is_action_released("build_cancel"):
		_cancel_all()
	elif event.is_action_released("build_confirm"):
		_confirm()


func _create_builder(building: BuildingDef) -> void:
	Events.builder_initiated.emit()
	
	# Just make sure we cancel all other build actions so we don't place multiple with one click
	_cancel_all()
	
	var builder: Builder = preload("res://object/builder/builder.tscn").instantiate()
	builder.building = building
	add_child(builder)
	builder.build_done.connect(self._on_build_done)


func _on_build_done(node: Node3D, building: BuildingDef, at_position: Vector3) -> void:
	energy_grid.add_building(node, at_position)
	
	# This is to prevent a case where the user selects a new building just after finishing another,
	# which causes two builders to be present simultaneously.
	if get_child_count() == 1:
		# Start another builder so we can place multiple buildings consecutively
		_create_builder(building)


func _confirm() -> void:
	if get_child_count() == 0:
		return
	
	var builder: Builder = get_child(0)
	builder.confirm()


func _cancel_all() -> void:
	for b: Builder in get_children():
		b.cancel()


func _set_buildings(value: Array[BuildingDef]) -> void:
	buildings = value
	
	if build_menu:
		build_menu.buildings = value


func _set_build_menu(value: BuildMenu) -> void:
	build_menu = value
	build_menu.build_initiated.connect(_create_builder)
	
	if buildings:
		build_menu.buildings = buildings
