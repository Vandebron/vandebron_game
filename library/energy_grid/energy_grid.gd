extends Node
class_name EnergyGrid # EnergyGrid

@export var target_frequency: float = 50.0
@export var frequency_tolerance: float = 0.05: set=_set_frequence_tolerance
@export var balance_adj_rate: float = 0.4

@onready var producer_container: Node3D = %Producers
@onready var consumer_container: Node3D = %Consumers
@onready var supply_lbl: RichTextLabel = %SupplyLbl
@onready var demand_lbl: RichTextLabel = %DemandLbl
@onready var frequency_lbl: RichTextLabel = %FrequencyLbl
@onready var grid_balance_gauge: GridBalanceGauge = %GridBalanceGauge

# Too much energy generated: frequency goes up.
# Demand for energy too high: frequency goes down.
# Extreme power supply: power plants disconnect.
# Extreme power demand: blackout.
var supply: float
var demand: float
var balance: float = 0.5 # Ranges between 0-1, so 0.5 means perfectly balanced.


func _physics_process(delta: float) -> void:
	supply = get_supply()
	demand = get_demand() # TODO: What if demand is zero? We get division by zero
	
	var target: float = supply / (supply + demand)
	var easing: float = ease(1.0 - abs(balance - target), 4.8) # Ease-in
	balance = clampf(lerpf(balance, target, delta * easing * balance_adj_rate), 0.0, 1.0)
	
	_update_ui()


func get_supply() -> float:
	return get_producers()\
		.map(func(a: Producer) -> float: return a.current_power)\
		.reduce(Utils.sumf, 0.0)


func get_demand() -> float:
	return get_consumers()\
		.map(func(a: Consumer) -> float: return a.demand)\
		.reduce(Utils.sumf, 0.0)


func get_producers() -> Array[Producer]:
	# TODO: We do result.assign() because of this: https://github.com/godotengine/godot/issues/72566
	var result: Array[Producer] = []
	result.assign(producer_container.get_children()
		.map(func(node: Node) -> Producer: return node as Producer))
	return result


func get_consumers() -> Array[Consumer]:
	# TODO: We do result.assign() because of this: https://github.com/godotengine/godot/issues/72566
	var result: Array[Consumer] = []
	result.assign(consumer_container.get_children()
		.map(func(node: Node) -> Consumer: return node as Consumer))
	return result


func add_producer(producer: Producer, at_position: Vector3) -> void:
	producer_container.add_child(producer)
	producer.global_position = at_position


func add_consumer(consumer: Consumer, at_position: Vector3) -> void:
	consumer_container.add_child(consumer)
	consumer.global_position = at_position


func _update_ui() -> void:
	supply_lbl.text = str("Supply\n", _precision2(supply), "kW")
	demand_lbl.text = str("[right]Demand\n", _precision2(demand), "kW[/right]")
	frequency_lbl.text = str("[center]", _precision2(_get_frequency()), "\nHz[/center]")
	grid_balance_gauge.supply = supply
	grid_balance_gauge.demand = demand
	grid_balance_gauge.balance = balance


func _get_frequency() -> float:
	return balance * target_frequency * 2.0


func _precision2(x: float) -> String:
	return str(x).pad_decimals(2)


func _set_frequence_tolerance(value: float) -> void:
	frequency_tolerance = value
	grid_balance_gauge.frequency_tolerance = frequency_tolerance
