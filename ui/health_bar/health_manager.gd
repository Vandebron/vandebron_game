class_name HealthManager extends Node

signal health_zeroed

@export var energy_grid: EnergyGrid
@export var heal_factor: float = 0.1
@export var hurt_factor: float = .25
@export var update_interval_ms: int = 100

const max_health: float = 100.0
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
	
	var frequency_diff_hz: float = absf(energy_grid.get_frequency_hz() - energy_grid.target_frequency_hz)
	
	if frequency_diff_hz < energy_grid.frequency_max_deviation_hz:
		health = min(health + heal_factor, max_health)
	else:
		health -= hurt_factor
	
	if health <= 0.0:
		health_zeroed.emit()
		_done = true
