extends Node
class_name EGrid # E=Energy


@export var producer_container: Node
@export var consumer_container: Node
@export var target_frequency: float = 50.0
@export var frequency_tolerance: float = 0.05

@onready var supply_lbl: RichTextLabel = %SupplyLbl
@onready var demand_lbl: RichTextLabel = %DemandLbl
@onready var frequency_lbl: RichTextLabel = %FrequencyLbl
@onready var grid_balance_gauge: ColorRect = %GridBalanceGauge

# Too much energy generated: frequency goes up.
# Demand for energy too high: frequency goes down.
# Extreme power supply: power plants disconnect.
# Extreme power demand: blackout.
var supply: float
var demand: float
var balance: float = 1.0
@export var balance_adj_rate: float = 0.01

func _physics_process(delta: float) -> void:
	supply = get_supply()
	demand = get_demand() # TODO: What if demand is zero? We get division by zero
	balance = lerpf(balance, supply / demand, delta * balance_adj_rate)
	
	_update_ui()


func get_supply() -> float:
	return get_producers()\
		.map(func(a: EAsset) -> float: return a.current_power)\
		.reduce(Utils.sumf, 0.0)


func get_demand() -> float:
	return get_consumers()\
		.map(func(a: Consumer) -> float: return a.demand)\
		.reduce(Utils.sumf, 0.0)


func get_producers() -> Array[EAsset]:
	# TODO: Refactor after this is fixed: https://github.com/godotengine/godot/issues/72566
	var result: Array[EAsset]
	result.assign(producer_container.get_children()
		.map(func(node: Node) -> EAsset: return node as EAsset))
	return result


func get_consumers() -> Array[Consumer]:
	# TODO: Refactor after this is fixed: https://github.com/godotengine/godot/issues/72566	
	var result: Array[Consumer]
	result.assign(consumer_container.get_children()
		.map(func(node: Node) -> Consumer: return node as Consumer))
	return result


#func topNProducers(n: int, producers: Array[EAsset]) -> Array[EAsset]:
	#producers.sort_custom(sort_by_power) # TODO: Sort mutates array; don't do that?
	#return producers.slice(0, min(n, producers.size()))


#func sort_by_power(a: EAsset, b: EAsset) -> bool:
	#return a.current_power < b.current_power


func _update_ui() -> void:
	supply_lbl.text = str("Supply\n", supply, "kW")
	demand_lbl.text = str("[right]Demand\n", demand, "kW[/right]")
	frequency_lbl.text = str("[center]", _frequency_to_string(_get_frequency()), "\nHz[/center]")
	grid_balance_gauge.supply = supply
	grid_balance_gauge.demand = demand
	grid_balance_gauge.balance = balance


func _get_frequency() -> float:
	return balance * target_frequency


func _frequency_to_string(freq: float) -> String:
	return str(freq).pad_decimals(2)
