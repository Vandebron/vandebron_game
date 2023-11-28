extends Node
class_name EGrid # E=Energy


@export var asset_container: Node
@export var target_frequency: float = 50.0
@export var frequency_tolerance: float = 0.05

# Too much energy generated: frequency goes up.
# Demand for energy too high: frequency goes down.
# Extreme power supply: power plants disconnect.
# Extreme power demand: blackout.
var frequency: float

# TSO = Tennet
# BRP = Balansbeheerder - producer, large consumer, supplier or trader

func _physics_process(delta: float) -> void:
	var total_power := 0.0
	var assets := get_assets()
	for asset in assets:
		total_power += asset.current_power
	frequency = total_power / assets.size()
	# TODO: Punish topNProducers(3, assets)


func get_assets() -> Array[EAsset]:
	return asset_container.get_children()\
		.map(func(node: Node) -> EAsset: return node as EAsset)


func topNProducers(n: int, producers: Array[EAsset]) -> Array[EAsset]:
	producers.sort_custom(sort_by_power) # TODO: Sort mutates array; don't do that?
	return producers.slice(0, min(n, producers.size()))


func sort_by_power(a: EAsset, b: EAsset) -> bool:
	return a.current_power < b.current_power
