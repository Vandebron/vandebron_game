extends Node3D

@export var energy_grid: EnergyGrid


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
	add_child(builder)
	builder.build_done.connect(self._on_build_done)


func _on_build_done(node: Node3D, building: BuildingDef, at_position: Vector3) -> void:
	if node.is_in_group(Constants.GROUP_PRODUCER):
		energy_grid.add_producer(node, at_position)
	elif node.is_in_group(Constants.GROUP_CONSUMER):
		energy_grid.add_consumer(node, at_position)
	elif node.is_in_group(Constants.GROUP_BATTERY):
		energy_grid.add_battery(node, at_position)
	else:
		printerr("Trying to add unknown building type to world")
	
	# This is to prevent a case where the user selects a new building just after finishing another,
	# which causes two builders to be present simultaneously.
	if get_child_count() == 1:
		# Start another builder so we can place multiple buildings consecutively
		_create_builder(building)
