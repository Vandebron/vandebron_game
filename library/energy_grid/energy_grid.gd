extends Node3D
class_name EnergyGrid

const BALANCE_CENTER: float = 0.5

@export var target_frequency_hz: float = 50.0
@export var frequency_max_deviation_hz: float = 0.1
@export var balance_adj_rate: float = 0.4

@onready var producer_container: Node3D = $Producers
@onready var consumer_container: Node3D = $Consumers
@onready var battery_container: Node3D = $Batteries

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
	_ingest_children()


func _physics_process(delta: float) -> void:
	_update_supply()
	demand = _get_demand() # TODO: What if demand is zero? We get division by zero
	_update_batteries()
	
	var target: float = supply / (supply + demand)
	var easing: float = ease(1.0 - abs(balance - target), 4.8) # Ease-in
	balance = clampf(lerpf(balance, target, delta * easing * balance_adj_rate), 0.0, 1.0)


func add_building(node: Node3D, at_position: Vector3) -> void:
	if node.is_in_group(Constants.GROUP_PRODUCER):
		add_producer(node, at_position)
	elif node.is_in_group(Constants.GROUP_CONSUMER):
		add_consumer(node, at_position)
	elif node.is_in_group(Constants.GROUP_BATTERY):
		add_battery(node, at_position)
	else:
		printerr("Trying to add unknown building type to world")


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
	if producer.owner:
		producer.reparent(producer_container)
	else:
		producer_container.add_child(producer)
	producer.global_position = at_position


func add_consumer(consumer: Consumer, at_position: Vector3) -> void:
	if consumer.owner:
		consumer.reparent(consumer_container)
	else:
		consumer_container.add_child(consumer)
	consumer.global_position = at_position


func add_battery(battery: Battery, at_position: Vector3) -> void:
	if battery.owner:
		battery.reparent(battery_container)
	else:
		battery_container.add_child(battery)
	battery.global_position = at_position


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


func _get_demand() -> float:
	return get_consumers()\
		.map(func(a: Consumer) -> float: return a.demand)\
		.reduce(Utils.sumf, 0.0)


func _ingest_children() -> void:
	var exclude: Array[Node] = [producer_container, consumer_container, battery_container]
	for child: Node in get_children():
		if child in exclude:
			continue
		var at_position: Vector3 = child.global_position
		add_building(child, at_position)
