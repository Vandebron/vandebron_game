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
	return get_node("/root/Main/%SubViewport")
	
	
func get_physics_layer(layer_name: String) -> int:
	return physics_layers[layer_name]


func sumf(accumulator: float, number: float) -> float:
	return accumulator + number


## Returns a value between -1 and 1, based on the current time.
## It returns -1 at the start of the time time cycle, and 1 at the end.
## Convenient for sampling points on a curve. Especially sine waves.
func get_cycle_value(cycle_time_ms: int) -> float:
	var current_time_ms: int = Time.get_ticks_msec()
	return 1.0 - (2.0 * (current_time_ms % cycle_time_ms)) / cycle_time_ms


## Returns a value between 0 and 1.
## Input values work like this:
##   -1 yields 0
##    0 yields 1
##    1 yields 0
func sine_y(x: float) -> float:
	return .5 * cos(x * PI) + .5


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
