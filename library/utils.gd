extends Node

# State
var physics_layers: Dictionary # [layer_name: String, layer_id: int]


func _init() -> void:
	physics_layers = _get_layers_by_name("3d_physics")


func get_camera() -> Camera3D:
	return get_node("/root/Main/%Camera3D")


func get_viewport_container() -> SubViewportContainer:
	return get_node("/root/Main/%SubViewportContainer")


func get_actual_viewport() -> Viewport:
	#return get_node("/root/Main/%SubViewport")
	return get_viewport()
	
	
func get_physics_layer(layer_name: String) -> int:
	return physics_layers[layer_name]


func _get_layers_by_name(type: String) -> Dictionary:
	var layers: Dictionary = {}
	for i in range(1, 33):
		var setting_name: String = str("layer_names/", type, "/layer_", i)
		var layer_name: String = ProjectSettings.get_setting(setting_name)
		if !layer_name:
			continue
		var bit: int = 2 ** (i - 1) # You know, because binary (btw, ** = pow())
		layers[layer_name] = bit
	return layers
