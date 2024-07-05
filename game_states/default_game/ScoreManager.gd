class_name BudgetManager extends Node

@export var energy_grid: EnergyGrid
@export var update_interval_ms: int = 150

var _update_timer: Timer

var budget: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_timer = Timer.new()
	_update_timer.wait_time = update_interval_ms / 1000.0
	_update_timer.timeout.connect(update)
	add_child(_update_timer)
	_update_timer.start()


func update() -> void:	
	var frequency_diff_hz: float = absf(energy_grid.get_frequency_hz() - energy_grid.target_frequency_hz)
	
	if frequency_diff_hz < energy_grid.frequency_max_deviation_hz:	
		budget += energy_grid.get_consumer_count() / 4
	else:
		budget = max(budget - energy_grid.get_consumer_count() / 8, 0)
	print("updated pudget")
