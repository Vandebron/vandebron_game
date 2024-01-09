extends Consumer

@export var consumption_variance: float = 0.05 # Deviation from consumption
@export var demand_adj_rate: float = 0.7 # How quickly demand changes

@onready var model: Model = $Model
@onready var variance_timer: Timer = $VarianceTimer

var _variance: float = 0.1 # Represents random consumption deviation per house
var _target_demand: float = 1.0


func _process(delta: float) -> void:
	# TODO: Maybe houses turn down heating during the night to save power?
	var heating: float = clampf(1.0 - weather.temperature - _variance, 0.0, 1.0) * max_demand
	
	_target_demand = heating # TODO: Should be "_target_demand = heating + appliances + car + etc"
	demand = lerpf(demand, _target_demand, delta * demand_adj_rate)


func on_added_to_grid() -> void:
	variance_timer.timeout.connect(self._update_variance)
	
	clock.part_of_day_started.connect(self._on_part_of_day_started)
	clock.part_of_day_ended.connect(self._on_part_of_day_ended)


## Introduces some randomness to consumption, so every house is a little bit different.
func _update_variance() -> void:
	_variance = randf() * consumption_variance


func _on_part_of_day_started(part: Clock.DayPart) -> void:
	if part == Clock.DayPart.DUSK:
		model.animation_player.play("night")


func _on_part_of_day_ended(part: Clock.DayPart) -> void:
	if part == Clock.DayPart.DUSK:
		model.animation_player.play("RESET")
