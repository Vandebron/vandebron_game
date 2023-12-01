extends Node
class_name EGrid # E=Energy

@export var target_frequency: float = 50.0
@export var frequency_tolerance: float = 0.05

@onready var producer_container: Node3D = %Producers
@onready var consumer_container: Node3D = %Consumers
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
	balance = lerpf(balance, supply / demand, delta * balance_adj_rate) # TODO: Apply ease-in-out
	
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
