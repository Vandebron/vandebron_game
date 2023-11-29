extends Node3D

const native_resolution := Vector2i(320, 180)

var builder: Builder


func _ready() -> void:
	Events.build_initiated.connect(self._on_build_initiated)
	
	# TODO: We could turn this on to get a heavily pixelated aesthetic
	#_resize_subviewport()
	#get_tree().root.size_changed.connect(self._resize_subviewport)


func _on_build_initiated(building: BuildingDef) -> void:
	if builder:
		builder.queue_free()
	
	builder = preload("res://object/builder/builder.tscn").instantiate()
	builder.building = building
	%World.add_child(builder)


func _resize_subviewport() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var resolution_downscale_factor: int = floori(viewport_size.y / native_resolution.y)
	resolution_downscale_factor = max(1, resolution_downscale_factor - 2)
	Utils.get_viewport_container().stretch_shrink = resolution_downscale_factor
