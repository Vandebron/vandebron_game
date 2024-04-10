class_name Battery extends EnergyAsset

@export var max_charge_kw: float = 1000.0
@export var charge_kw_per_sec: float = 60.0

@onready var model: BatteryModel = $Model

var state_of_charge_kw: float


func _init() -> void:
	add_to_group(Constants.GROUP_BATTERY)


func _process(delta: float) -> void:
	model.charge_percentage = state_of_charge_kw / max_charge_kw


func get_model() -> Model:
	return model


## Tries to store the given amount of kW in the battery, i.e. charging it.
## Returns the amount it succesfully stored.
func give(requested_kw: float, delta: float) -> float:
	var charged_kw = min(delta * charge_kw_per_sec, requested_kw)
	var remainder: float = (state_of_charge_kw + charged_kw) - max_charge_kw
	if remainder > 0.0:
		state_of_charge_kw = max_charge_kw
		# Float rounding will sometimes make it return 0.0000000000004 here, even though it's 0.0.
		if is_zero_approx(charged_kw - remainder):
			return 0.0
		else:
			return charged_kw - remainder
	else:
		state_of_charge_kw += charged_kw
		return charged_kw


## Tries to draw the given amount of kW from the battery, i.e. discharging it.
## Returns the amount it succesfully discharged.
func take(requested_kw: float, delta: float) -> float:
	var discharged_kw = min(delta * charge_kw_per_sec, requested_kw)
	var remainder: float = state_of_charge_kw - discharged_kw
	if remainder < 0.0:
		state_of_charge_kw = 0.0
		return discharged_kw + remainder
	else:
		state_of_charge_kw -= discharged_kw
		return discharged_kw


func on_added_to_grid() -> void:
	pass
