extends Node3D

@export var energy_grid: EnergyGrid
@export var camera: Camera3D


func _ready() -> void:
	Events.build_initiated.connect(self._create_builder)


func _input(event: InputEvent) -> void:
	if event.is_action_released("build_cancel"):
		Events.build_cancelled.emit()
	elif event.is_action_released("build_confirm"):
		Events.build_confirmed.emit()


func _create_builder(building: BuildingDef) -> void:
	# Just make sure we cancel all other build actions so we don't place multiple with one click
	for b: Builder in get_children():
		b.cancel()
	
	var builder: Builder = preload("res://object/builder/builder.tscn").instantiate()
	builder.building = building
	builder.camera = camera
	add_child(builder)
	builder.build_done.connect(self._on_build_done)


func _on_build_done(node: Node3D, building: BuildingDef, at_position: Vector3) -> void:
	energy_grid.add_building(node, at_position)
	
	# This is to prevent a case where the user selects a new building just after finishing another,
	# which causes two builders to be present simultaneously.
	if get_child_count() == 1:
		# Start another builder so we can place multiple buildings consecutively
		_create_builder(building)
