extends Node
class_name HealthManager

@export var grid: EnergyGrid
@export var heal_factor: float = 0.01
@export var hurt_factor: float = 0.01

var health: float = 50.0


func _physics_process(_delta: float) -> void:
	var balance_diff: float = abs(grid.BALANCE_CENTER - grid.balance)
	var balance_diff_hz: float = balance_diff * grid.target_frequency_hz
	var deviation: float = balance_diff_hz / grid.frequency_max_deviation_hz
	
	if balance_diff_hz < grid.frequency_max_deviation_hz:
		health += heal_factor
	else:
		health -= deviation * hurt_factor
	
	if is_zero_approx(health):
		pass # TODO: Game over
