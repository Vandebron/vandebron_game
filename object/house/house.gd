extends Consumer

@export var consumption_variance: float = 0.05 # Deviation from consumption
@export var demand_adj_rate: float = 0.7 # How quickly demand changes

@onready var model: Model = $Model
@onready var variance_timer: Timer = $VarianceTimer

var _variance: float = 0.1 # Represents random consumption deviation per house
var _target_demand: float = 1.0


func _physics_process(delta: float) -> void:
	# TODO: Maybe houses turn down heating during the night to save power?
	var heating: float = clampf(1.0 - weather.temperature - _variance, 0.0, 1.0) * max_demand
	
	_target_demand = heating # TODO: Should be "_target_demand = heating + appliances + car + etc"
	demand = lerpf(demand, _target_demand, delta * demand_adj_rate)
	
	#if Input.is_action_pressed("show_info"):
		#show_info()


func _input(event: InputEvent) -> void:
	if event.is_action_released("show_info"):
		hide_info()


func on_added_to_grid() -> void:
	variance_timer.timeout.connect(self._update_variance)
	
	weather.part_of_day_started.connect(self._on_part_of_day_started)
	weather.part_of_day_ended.connect(self._on_part_of_day_ended)

	#if weather.is_day():
		#model.animation_player.play("consume")


#func show_info() -> void:
	#%ConsumptionGaugeCtnr.visible = true
	#%ConsumptionGaugeCtnr.global_position = Utils.get_camera().unproject_position(global_position)
	#%ConsumptionGaugeCtnr.position -= %ConsumptionGaugeCtnr.size / 2.0 # Center it based on its size
	#%ConsumptionGaugeCtnr.position.y -= 30.0 # Nudge it up a little
	#
	#%ConsumptionGauge.current = demand
	#%ConsumptionGauge.target = _target_demand
	#%ConsumptionGauge.max_value = max_demand
	#
	#%kwLbl.text = str(demand).pad_decimals(1) + "kW"


func hide_info() -> void:
	%ConsumptionGaugeCtnr.visible = false


## Introduces some randomness to consumption, so every house is a little bit different.
func _update_variance() -> void:
	_variance = randf() * consumption_variance


func _on_part_of_day_started(part: Weather.DayPart) -> void:
	if part == Weather.DayPart.DUSK:
		model.animation_player.play("night")


func _on_part_of_day_ended(part: Weather.DayPart) -> void:
	#if part == Weather.DayPart.DUSK:
		#model.animation_player.play("consume")
	pass
