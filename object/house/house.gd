extends Consumer

@export var consumption_variance: float = 0.05 # Deviation from consumption
@export var demand_adj_rate: float = 0.7 # How quickly demand changes

@onready var model: Model = $Model
@onready var variance_timer: Timer = $VarianceTimer

var _variance: float = 0.1 # Represents random consumption deviation per house
var _target_demand: float = 1.0


func _ready() -> void:
	variance_timer.timeout.connect(self._update_variance)

	if Weather.is_day():
		model.animation_player.play("consume")
	
	Events.night_started.connect(func() -> void:
		model.animation_player.play("night"))
	
	Events.night_ended.connect(func() -> void:
		model.animation_player.play("consume"))


func _physics_process(delta: float) -> void:
	# TODO: Maybe houses turn down heating during the night to save power?
	var heating: float = clampf(1.0 - Weather.temperature - _variance, 0.0, 1.0) * max_demand
	
	_target_demand = heating # TODO: Should be "_target_demand = heating + appliances + car + etc"
	demand = lerpf(demand, _target_demand, delta * demand_adj_rate)
	
	if Input.is_action_pressed("show_info"):
		show_info()


func _input(event: InputEvent) -> void:
	if event.is_action_released("show_info"):
		hide_info()


## Introduces some randomness to consumption, so every house is a little bit different.
func _update_variance() -> void:
	_variance = randf() * consumption_variance


func show_info() -> void:
	$ConsumptionGauge.visible = true
	$ConsumptionGauge.global_position = Utils.get_camera().unproject_position(global_position)
	$ConsumptionGauge.current = demand
	$ConsumptionGauge.target = _target_demand
	$ConsumptionGauge.max_value = max_demand


func hide_info() -> void:
	$ConsumptionGauge.visible = false
