extends Node3D
class_name EnergyGrid

const BALANCE_CENTER: float = 0.5

@export var target_frequency_hz: float = 50.0
@export var frequency_max_deviation_hz: float = 0.1
@export var balance_adj_rate: float = 0.4
@export var clock: Clock
@export var weather: Weather

# Buildings
var _producers: Array[Producer] = []
var _consumers: Array[Consumer] = []
var _batteries: Array[Battery] = []

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
	_ingest_buildings()


func _process(delta: float) -> void:
	_update_supply()
	demand = _get_demand() # TODO: What if demand is zero? We get division by zero
	_update_batteries()
	
	var target: float = supply / (supply + demand)
	var easing: float = ease(1.0 - absf(balance - target), 4.8) # Ease-in
	balance = clampf(lerpf(balance, target, delta * easing * balance_adj_rate), 0.0, 1.0)


func add_building(node: Node3D, at_position: Vector3) -> void:
	if node is Producer:
		add_producer(node, at_position)
	elif node is Consumer:
		add_consumer(node, at_position)
	elif node is Battery:
		add_battery(node, at_position)
	else:
		printerr("Trying to add unknown building type to world")


func add_producer(producer: Producer, at_position: Vector3) -> void:
	if producer.owner:
		producer.reparent(self)
	else:
		add_child(producer)
	producer.global_position = at_position
	producer.clock = clock
	producer.weather = weather
	producer.on_added_to_grid()
	_producers.append(producer)


func add_consumer(consumer: Consumer, at_position: Vector3) -> void:
	if consumer.owner:
		consumer.reparent(self)
	else:
		add_child(consumer)
	consumer.global_position = at_position
	consumer.clock = clock
	consumer.weather = weather
	consumer.on_added_to_grid()
	_consumers.append(consumer)


func add_battery(battery: Battery, at_position: Vector3) -> void:
	if battery.owner:
		battery.reparent(self)
	else:
		add_child(battery)
	battery.global_position = at_position
	battery.on_added_to_grid()
	_batteries.append(battery)


func _update_supply() -> void:
	fossil = 0.0
	solar = 0.0
	wind = 0.0
	
	for producer in _producers:
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
		for battery in _batteries:
			var stored_kw: float = battery.give(diff_kw)
			supply -= stored_kw # TODO: Fix ugly side-effect
			diff_kw -= stored_kw
			if diff_kw <= 0.0:
				break
	else:
		diff_kw = absf(diff_kw)
		for battery in _batteries:
			var discharged_kw: float = battery.take(diff_kw)
			supply += discharged_kw # TODO: Fix ugly side-effect
			diff_kw -= discharged_kw
			if diff_kw <= 0.0:
				break


func _get_demand() -> float:
	return _consumers\
		.map(func(a: Consumer) -> float: return a.demand)\
		.reduce(Utils.sumf, 0.0)


func _ingest_buildings() -> void:
	for child: Node in get_children():
		var at_position: Vector3 = child.global_position
		add_building(child, at_position)
