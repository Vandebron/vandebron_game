extends Node3D

const native_resolution := Vector2i(320, 180)

@export var egrid: EGrid

var builder: Builder


func _ready() -> void:
	Events.build_initiated.connect(self._on_build_initiated)
	
	# TODO: We could turn this on to get a heavily pixelated aesthetic
	#_resize_subviewport()
	#get_tree().root.size_changed.connect(self._resize_subviewport)


func _input(event: InputEvent) -> void:
	if builder && is_instance_valid(builder):
		if event is InputEventMouseButton && event.is_released():
			if event.button_index == MOUSE_BUTTON_LEFT:
				builder.confirm()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				builder.cancel()


func _on_build_initiated(building: BuildingDef) -> void:
	if builder && is_instance_valid(builder):
		builder.queue_free()
	
	builder = preload("res://object/builder/builder.tscn").instantiate()
	builder.building = building
	%World.add_child(builder)
	builder.build_done.connect(self._add_new_building_to_world)


func _add_new_building_to_world(node: Node3D, at_position: Vector3) -> void:
	if node.is_in_group(Constants.GROUP_PRODUCER):
		egrid.add_producer(node, at_position)
	elif node.is_in_group(Constants.GROUP_CONSUMER):
		egrid.add_consumer(node, at_position)
	else:
		printerr("Trying to add unknown building type to world")


func _resize_subviewport() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var resolution_downscale_factor: int = floori(viewport_size.y / native_resolution.y)
	resolution_downscale_factor = max(1, resolution_downscale_factor - 2)
	Utils.get_viewport_container().stretch_shrink = resolution_downscale_factor
