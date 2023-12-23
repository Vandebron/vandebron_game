extends Node3D
class_name HealthManager

@export var health_bar: HealthBar
@export var heal_factor: float = 0.01
@export var hurt_factor: float = 0.01


func update_health(grid: EnergyGrid) -> void:
	var balance_diff: float = abs(grid.BALANCE_CENTER - grid.balance)
	var balance_diff_hz: float = balance_diff * grid.target_frequency_hz
	var deviation: float = balance_diff_hz / grid.frequency_max_deviation_hz
	
	if balance_diff_hz < grid.frequency_max_deviation_hz:
		health_bar.health += heal_factor
	else:
		health_bar.health -= deviation * hurt_factor
	
	if is_zero_approx(health_bar.health):
		pass # TODO: Game over
