extends Node3D
class_name Battery

@export var max_charge_kw: float = 1.0

@onready var model: BatteryModel = $Model

var state_of_charge_kw: float


func _init() -> void:
	add_to_group(Constants.GROUP_BATTERY)


func _process(_delta: float) -> void:
	model.charge_percentage = state_of_charge_kw / max_charge_kw


## Tries to store the given amount of kW in the battery, i.e. charging it.
## Returns the amount it succesfully stored.
func give(kw: float) -> float:
	var remainder: float = (state_of_charge_kw + kw) - max_charge_kw
	if remainder > 0.0:
		state_of_charge_kw = max_charge_kw
		return kw - remainder
	else:
		state_of_charge_kw += kw
		return kw


## Tries to draw the given amount of kW from the battery, i.e. discharging it.
## Returns the amount it succesfully discharged.
func take(kw: float) -> float:
	var remainder: float = state_of_charge_kw - kw
	if remainder < 0.0:
		state_of_charge_kw = 0.0
		return kw + remainder
	else:
		state_of_charge_kw -= kw
		return kw


func on_added_to_grid() -> void:
	pass
