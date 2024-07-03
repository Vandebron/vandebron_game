extends Node3D
class_name EnergyAsset

signal removed


func update_power(_clock: Clock, _weather: Weather) -> void:
	pass


func on_added_to_grid(_clock: Clock, _weather: Weather) -> void:
	pass


func get_model() -> Model:
	assert(false, "Please implement this method")
	return null
