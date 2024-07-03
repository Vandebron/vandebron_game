class_name Consumer extends EnergyAsset

@export var demand: float
@export var max_demand: float


func _init() -> void:
	add_to_group(Constants.GROUP_CONSUMER)


func on_added_to_grid(_clock: Clock, _weather: Weather) -> void:
	pass
