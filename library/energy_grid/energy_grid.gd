extends Node
class_name EnergyGrid # EnergyGrid

const BALANCE_CENTER: float = 0.5

@export var target_frequency_hz: float = 50.0
@export var frequency_max_deviation_hz: float = 0.1: set=_set_frequency_max_deviation_hz
@export var balance_adj_rate: float = 0.4

@onready var producer_container: Node3D = %Producers
@onready var consumer_container: Node3D = %Consumers
@onready var battery_container: Node3D = %Batteries
@onready var supply_lbl: RichTextLabel = %SupplyLbl
@onready var demand_lbl: RichTextLabel = %DemandLbl
@onready var hz_lbl: Label = %HzLbl
@onready var hz_ctnr: ColorRect = %HzCtnr
@onready var grid_balance_gauge: GridBalanceGauge = %GridBalanceGauge
@onready var health_bar: PanelContainer = %HealthBar
@onready var health_manager: HealthManager = $HealthManager

# Supply kW
var fossil: float
var solar: float
var wind: float
var supply: float # Total of fossil + solar + wind

# Demand kW
var demand: float

# Supply / demand = balance (calculated as fraction, displayed as Hz)
var balance: float = 0.5 # Ranges between 0-1, so 0.5 means perfectly balanced.


func _ready() -> void:
	grid_balance_gauge.frequency_max_deviation = _get_normalized_frequency_max_deviation()


func _physics_process(delta: float) -> void:
	_update_supply()
	demand = get_demand() # TODO: What if demand is zero? We get division by zero
	_update_batteries()
	
	var target: float = supply / (supply + demand)
	var easing: float = ease(1.0 - abs(balance - target), 4.8) # Ease-in
	balance = clampf(lerpf(balance, target, delta * easing * balance_adj_rate), 0.0, 1.0)
	
	health_manager.update_health(self)
	_update_ui()


func _update_supply() -> void:
	fossil = 0.0
	solar = 0.0
	wind = 0.0
	
	for producer in get_producers():
		match producer.type:
			Producer.Type.FOSSIL:
				fossil += producer.current_power
			Producer.Type.SOLAR:
				solar += producer.current_power
			Producer.Type.WIND:
				wind += producer.current_power
	
	supply = fossil + solar + wind


func _update_batteries() -> void:
	var diff_kw: float = supply - demand
	if diff_kw >= 0.0:
		for battery in get_batteries():
			var stored_kw: float = battery.give(diff_kw)
			supply -= stored_kw # TODO: Fix ugly side-effect
			diff_kw -= stored_kw
			if diff_kw <= 0.0:
				break
	else:
		diff_kw = abs(diff_kw)
		for battery in get_batteries():
			var discharged_kw: float = battery.take(diff_kw)
			supply += discharged_kw # TODO: Fix ugly side-effect
			diff_kw -= discharged_kw
			if diff_kw <= 0.0:
				break


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


func get_batteries() -> Array[Battery]:
	# TODO: We do result.assign() because of this: https://github.com/godotengine/godot/issues/72566
	var result: Array[Battery] = []
	result.assign(battery_container.get_children()
		.map(func(node: Node) -> Battery: return node as Battery))
	return result


func add_producer(producer: Producer, at_position: Vector3) -> void:
	producer_container.add_child(producer)
	producer.global_position = at_position


func add_consumer(consumer: Consumer, at_position: Vector3) -> void:
	consumer_container.add_child(consumer)
	consumer.global_position = at_position


func add_battery(battery: Battery, at_position: Vector3) -> void:
	battery_container.add_child(battery)
	battery.global_position = at_position


func _update_ui() -> void:
	supply_lbl.text = str("[right]SUPPLY\n", _precision2(supply), " kW[/right]")
	demand_lbl.text = str("DEMAND\n", _precision2(demand), " kW")
	hz_lbl.text = str(_precision2(_get_frequency_hz()), " Hz")
	hz_ctnr.position.x = (balance * grid_balance_gauge.size.x) - (hz_ctnr.size.x / 2)
	grid_balance_gauge.fossil = fossil
	grid_balance_gauge.wind = wind
	grid_balance_gauge.solar = solar
	grid_balance_gauge.demand = demand
	grid_balance_gauge.balance = balance


func _get_frequency_hz() -> float:
	return balance * target_frequency_hz * 2.0


func _set_frequency_max_deviation_hz(value: float) -> void:
	frequency_max_deviation_hz = value
	if grid_balance_gauge:
		grid_balance_gauge.frequency_max_deviation = _get_normalized_frequency_max_deviation()


func _get_normalized_frequency_max_deviation() -> float:
	return frequency_max_deviation_hz / target_frequency_hz


func _precision2(x: float) -> String:
	return str(x).pad_decimals(2)
