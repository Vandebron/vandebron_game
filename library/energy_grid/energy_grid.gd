class_name EnergyGrid extends Node3D

const BALANCE_CENTER: float = 0.5

@export var target_frequency_hz: float = 50.0
@export var frequency_max_deviation_hz: float = 0.1
@export var balance_adj_rate: float = 1.0
@export var clock: Clock
@export var weather: Weather

@onready var power_update_timer: Timer = $PowerUpdateTimer

# Buildings
var _producers: Array[Producer] = []
var _consumers: Array[Consumer] = []
var _batteries: Array[Battery] = []

# Supply kW
var fossil: float
var solar: float
var wind: float
var battery_discharge: float
var supply: float # Total of fossil + solar + wind

# Demand kW
var demand: float

# Supply / demand = balance (calculated as fraction, displayed as Hz)
var balance: float = 0.5 # Ranges between 0-1, so 0.5 means perfectly balanced.

func get_consumers_positions() -> Array[Vector3]:
	var bla: Array[Vector3]
	bla.assign(_consumers.map(func (c): return c.global_position))
	return bla
	
func get_all_positions() -> Array[Vector3]:
	var bla: Array[Vector3] = []
	bla.append_array(_producers.map(func (c): return c.global_position))
	bla.append_array(_consumers.map(func (c): return c.global_position))
	bla.append_array(_batteries.map(func (c): return c.global_position))
	return bla

func _ready() -> void:
	_ingest_buildings()
	_update_power(power_update_timer.wait_time)
	
	power_update_timer.timeout.connect(_update_power.bind(power_update_timer.wait_time))


func _process(delta: float) -> void:
	balance = _calculate_balance(delta)


func _update_power(delta: float) -> void:
	_update_supply()
	demand = _get_demand()
	_update_batteries(delta)
	balance = _calculate_balance(delta)


#Here 
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
	if producer.is_inside_tree():
		producer.reparent(self)
	else:
		add_child(producer)
	producer.global_position = at_position
	producer.clock = clock
	producer.weather = weather
	producer.on_added_to_grid()
	producer.removed.connect(_remove_producer)
	_producers.append(producer)


func add_consumer(consumer: Consumer, at_position: Vector3) -> void:
	if consumer.is_inside_tree():
		consumer.reparent(self)
	else:
		add_child(consumer)
	consumer.global_position = at_position
	consumer.clock = clock
	consumer.weather = weather
	consumer.on_added_to_grid()
	consumer.removed.connect(_remove_consumer)
	_consumers.append(consumer)


func add_battery(battery: Battery, at_position: Vector3) -> void:
	if battery.is_inside_tree():
		battery.reparent(self)
	else:
		add_child(battery)
	battery.global_position = at_position
	battery.on_added_to_grid()
	battery.removed.connect(_remove_battery)
	_batteries.append(battery)


func get_frequency_hz() -> float:
	return balance * target_frequency_hz * 2.0

func get_consumer_count() -> int:
	return _consumers.size()

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


func _get_demand() -> float:
	return _consumers\
		.map(func(a: Consumer) -> float: return a.demand)\
		.reduce(Utils.sumf, 0.0)


func _update_batteries(delta: float) -> void:
	battery_discharge = 0.0
	var diff_kw: float = supply - demand
	if diff_kw >= 0.0:
		for battery in _batteries:
			var stored_kw: float = battery.give(diff_kw, delta)
			supply -= stored_kw # TODO: Fix ugly side-effect
			diff_kw -= stored_kw
			if diff_kw <= 0.0:
				break
	else:
		diff_kw = absf(diff_kw)
		for battery in _batteries:
			var discharged_kw: float = battery.take(diff_kw, delta)
			supply += discharged_kw # TODO: Fix ugly side-effect
			diff_kw -= discharged_kw
			battery_discharge += discharged_kw / 2.0 # Division by 2 is because of supply side-effect
			if diff_kw <= 0.0:
				break


func _calculate_balance(delta: float) -> float:
	const POW: float = 4.0
	
	if is_zero_approx(demand):
		demand = 1.0
	
	var supply_demand_ratio: float = supply / (supply + demand)
	
	# This formula produces a U-shaped or V-shaped graph, depending on the value of POW.
	# We do this so our frequency doesn't fluctuate wildly as soon as we have imbalance.
	# By changing the POW value, we can essentially control the difficulty of the game.
	# A POW value of 4 = U-shaped, and 2 = V-shaped.
	# U-shaped makes the game easier, while V-shaped makes it harder.
	# If supply=100%, demand=0%, the result is 1.0.
	# If supply=50%, demand=50%, the result is 0.5.
	# If supply=0%, demand=100%, the result is 1.0.
	var target: float = 0.5 * (1.0 + pow(1.0 - 2.0 * supply_demand_ratio, POW))
	
	# Because pow() only produces positive numbers, we have a special case for negative imbalance.
	# There's probably a way to get rid of this if-statement. But I'm not good at math.
	if supply_demand_ratio < BALANCE_CENTER:
		target = BALANCE_CENTER - (target - BALANCE_CENTER)
	
	return clampf(lerpf(balance, target, delta * balance_adj_rate), 0.0, 1.0)


func _remove_producer(producer: Producer) -> void:
	_producers.erase(producer)


func _remove_consumer(consumer: Consumer) -> void:
	_consumers.erase(consumer)


func _remove_battery(battery: Battery) -> void:
	_batteries.erase(battery)


func _ingest_buildings() -> void:
	for child: Node in get_children():
		if !(child is EnergyAsset):
			continue
		var at_position: Vector3 = child.global_position
		add_building(child, at_position)
