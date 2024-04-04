class_name Consumer extends EnergyAsset

@export var demand: float
@export var max_demand: float
@export var clock: Clock
@export var weather: Weather


func _init() -> void:
	add_to_group(Constants.GROUP_CONSUMER)


func on_added_to_grid() -> void:
	pass
