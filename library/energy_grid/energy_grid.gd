class_name EnergyGrid extends Node3D

const BALANCE_CENTER: float = 0.5 # So, 0=undersupply, 1=oversupply

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


func _ready() -> void:
	call_deferred_thread_group("_ingest_buildings")
	set_process(false) # Don't update grid balance while we wait for buildings to load in


func _process(delta: float) -> void:
	balance = _calculate_balance(delta)


func _update_power(delta: float) -> void:
	_update_supply()
	_update_demand()
	_update_batteries(delta)
	balance = _calculate_balance(delta)


func add_building(asset: EnergyAsset, at_position: Vector3) -> void:
	if asset.is_inside_tree():
		asset.reparent(self)
	else:
		add_child(asset)
	asset.global_position = at_position
	asset.on_added_to_grid(clock, weather)
	asset.removed.connect(_deregister_building)
	_register_building(asset)


func _register_building(asset: EnergyAsset) -> void:
	if asset is Producer:
		_producers.append(asset)
	elif asset is Consumer:
		_consumers.append(asset)
	elif asset is Battery:
		_batteries.append(asset)
	else:
		printerr("Trying to register unknown building type to EnergyGrid")


func _deregister_building(node: Node3D) -> void:
	if node is Producer:
		_producers.erase(node)
	elif node is Consumer:
		_consumers.erase(node)
	elif node is Battery:
		_batteries.erase(node)
	else:
		printerr("Trying to de-register unknown building type from EnergyGrid")


func get_consumers_positions() -> Array[Vector3]:
	var result: Array[Vector3]
	result.assign(_consumers.map(func (x): return x.global_position))
	return result


func get_all_positions() -> Array[Vector3]:
	var result: Array[Vector3] = []
	result.append_array(_producers.map(func (x): return x.global_position))
	result.append_array(_consumers.map(func (x): return x.global_position))
	result.append_array(_batteries.map(func (x): return x.global_position))
	return result


func get_frequency_hz() -> float:
	return balance * target_frequency_hz * 2.0


func get_consumer_count() -> int:
	return _consumers.size()


func _update_supply() -> void:
	fossil = 0.0
	solar = 0.0
	wind = 0.0
	
	for producer in _producers:
		producer.update_power(clock, weather)
		match producer.type:
			Producer.Type.FOSSIL:
				fossil += producer.current_power
				print("fossil + " + str(fossil))
			Producer.Type.SOLAR:
				solar += producer.current_power
			Producer.Type.WIND:
				wind += producer.current_power
	
	supply = fossil + solar + wind
	print("supply + " + str(supply))


func _update_demand() -> void:
	demand = 0.0
	
	for consumer in _consumers:
		consumer.update_power(clock, weather)
		demand += consumer.demand
		print("demand + " + str(demand))


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


## Iterates all children of the EnergyGrid node and adds them to the grid if they're buildings.
## Why? Because that way you can pre-place some buildings in the editor.
func _ingest_buildings() -> void:
	for child: Node in get_children():
		# Placeholders are nodes you can see in the editor that aren't actually loaded in at
		# runtime. That makes the game load slightly faster. But that also means we'll have to
		# manually load them here
		if child.get_scene_instance_load_placeholder():
			child = (child as InstancePlaceholder).create_instance(true)
		# There might be some other nodes like timers, so skip those
		if !(child is EnergyAsset):
			continue
		
		var at_position: Vector3 = child.global_position
		add_building(child, at_position)
		_start_twirl_animation(child)
		await get_tree().create_timer(0.05).timeout
	
	# We can finally start the game, now that all the buildings have loaded in
	_update_power(power_update_timer.wait_time)
	set_process(true)
	power_update_timer.timeout.connect(_update_power.bind(power_update_timer.wait_time))


func _start_twirl_animation(building: EnergyAsset) -> Tween:
	var model: Model = building.get_model()
	var tween: Tween = create_tween()
	# Rise and twirl
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(model, "global_rotation:y", TAU, 0.4)
	tween.parallel().tween_property(model, "global_position:x", building.global_position.x, 0.4)
	tween.parallel().tween_property(model, "global_position:z", building.global_position.z, 0.4)
	tween.parallel().tween_property(model, "global_position:y", 0.8, 0.4)
	# Fall and bounce
	tween.chain()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.tween_property(model, "global_position:y", 0.0, 0.35)
	return tween
