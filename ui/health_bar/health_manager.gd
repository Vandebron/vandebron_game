extends Node
class_name HealthManager

signal health_zeroed

@export var energy_grid: EnergyGrid
@export var heal_factor: float = 0.01
@export var hurt_factor: float = 0.01
@export var update_interval_ms: int = 100

var health: float = 50.0
var _done: bool
var _update_timer: Timer


func _ready() -> void:
	_update_timer = Timer.new()
	_update_timer.wait_time = update_interval_ms / 1000.0
	_update_timer.timeout.connect(update)
	add_child(_update_timer)
	_update_timer.start()


func update() -> void:
	if _done:
		return # Hack - so we don't keep spamming the signal
	
	var balance_diff: float = absf(energy_grid.BALANCE_CENTER - energy_grid.balance)
	var balance_diff_hz: float = balance_diff * energy_grid.target_frequency_hz
	var deviation: float = balance_diff_hz / energy_grid.frequency_max_deviation_hz
	
	if balance_diff_hz < energy_grid.frequency_max_deviation_hz:
		health += heal_factor
	else:
		health -= deviation * hurt_factor
	
	if health <= 0.0:
		health_zeroed.emit()
		_done = true
