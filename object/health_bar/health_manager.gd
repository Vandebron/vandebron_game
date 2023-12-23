extends Node
class_name HealthManager

signal health_zeroed

@export var energy_grid: EnergyGrid
@export var heal_factor: float = 0.01
@export var hurt_factor: float = 0.01

var health: float = 50.0
var _done: bool


func _physics_process(_delta: float) -> void:
	if _done:
		return # Hack - so we don't keep spamming the signal
	
	var balance_diff: float = abs(energy_grid.BALANCE_CENTER - energy_grid.balance)
	var balance_diff_hz: float = balance_diff * energy_grid.target_frequency_hz
	var deviation: float = balance_diff_hz / energy_grid.frequency_max_deviation_hz
	
	if balance_diff_hz < energy_grid.frequency_max_deviation_hz:
		health += heal_factor
	else:
		health -= deviation * hurt_factor
	
	if health <= 0.0:
		health_zeroed.emit()
		_done = true
