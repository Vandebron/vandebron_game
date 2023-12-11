extends Node3D

const native_resolution := Vector2i(320, 180)

@export var energy_grid: EnergyGrid

@onready var sun_anchor: Node3D = $SunAnchor
@onready var sun: DirectionalLight3D = $SunAnchor/Sun
@onready var moon: DirectionalLight3D = $SunAnchor/Moon
@onready var build_item_list: BuildMenu = %BuildItemList


func _ready() -> void:
	Events.build_initiated.connect(self._create_builder)
	
	# TODO: We could turn this on to get a heavily pixelated aesthetic
	#_resize_subviewport()
	#get_tree().root.size_changed.connect(self._resize_subviewport)


func _physics_process(_delta: float) -> void:
	sun_anchor.rotation.z = PI * (1.0 - Weather.point_of_day)
	sun_anchor.rotation.y = PI * (1.0 - Weather.point_of_day)
	sun.visible = Weather.is_day()
	moon.visible = Weather.is_night()
	sun.look_at(Vector3.ZERO)
	moon.look_at(Vector3.ZERO)
	
	# TODO: Add dawn/dusk lighting style like this:
	#sun.light_color = Color.hex(0xd3a068ff)
	#sun.light_energy = 0.5
	#$WorldEnvironment.environment.fog_enabled = _is_night()


func _input(event: InputEvent) -> void:
	if event.is_action_released("build_initiate"):
		build_item_list.select_current_item()
	elif event.is_action_released("cycle_build_list_left"):
		build_item_list.cycle_left()
	elif event.is_action_released("cycle_build_list_right"):
		build_item_list.cycle_right()
	elif event.is_action_released("build_cancel"):
		Events.build_cancelled.emit()
	elif event.is_action_released("build_confirm"):
		Events.build_confirmed.emit()


func _create_builder(building: BuildingDef) -> void:
	# Just make sure we cancel all other build actions so we don't place multiple with one click
	for b: Builder in get_tree().get_nodes_in_group(Constants.GROUP_BUILDER):
		b.cancel()
	
	var builder: Builder = preload("res://object/builder/builder.tscn").instantiate()
	builder.building = building
	%World.add_child(builder)
	builder.build_done.connect(self._on_build_done)


func _on_build_done(node: Node3D, building: BuildingDef, at_position: Vector3) -> void:
	if node.is_in_group(Constants.GROUP_PRODUCER):
		energy_grid.add_producer(node, at_position)
	elif node.is_in_group(Constants.GROUP_CONSUMER):
		energy_grid.add_consumer(node, at_position)
	else:
		printerr("Trying to add unknown building type to world")
	
	# This is to prevent a case where the user selects a new building just after finishing another,
	# which causes two builders to be present simultaneously.
	if get_tree().get_nodes_in_group(Constants.GROUP_BUILDER).size() == 1:
		# Start another builder so we can place multiple buildings consecutively
		_create_builder(building)


func _resize_subviewport() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var resolution_downscale_factor: int = floori(viewport_size.y / native_resolution.y)
	resolution_downscale_factor = max(1, resolution_downscale_factor - 2)
	Utils.get_viewport_container().stretch_shrink = resolution_downscale_factor
