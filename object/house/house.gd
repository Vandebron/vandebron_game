extends Consumer

@onready var model: Model = $Model


func update_power(_clock: Clock, weather: Weather) -> void:
	# TODO: Maybe houses turn down heating during the night to save power?
	var heating: float = clampf(1.0 - weather.temperature, 0.0, 1.0) * max_demand
	demand = heating # TODO: Should be "_target_demand = heating + appliances + car + etc"


func on_added_to_grid(clock: Clock, _weather: Weather) -> void:
	clock.part_of_day_started.connect(self._on_part_of_day_started)
	clock.part_of_day_ended.connect(self._on_part_of_day_ended)


func get_model() -> Model:
	return model


func _on_part_of_day_started(part: Clock.DayPart) -> void:
	if part == Clock.DayPart.DUSK:
		model.animation_player.play("night")


func _on_part_of_day_ended(part: Clock.DayPart) -> void:
	if part == Clock.DayPart.DUSK:
		model.animation_player.play("RESET")
