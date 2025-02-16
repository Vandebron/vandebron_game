extends Node
class_name UiManager

const update_interval_ms: float = 100.0
var BAD_COLOR: Color = Color.hex(0xfc806fff)
var DEFAULT_COLOR: Color = Color.hex(0x333d47ff)

@export var energy_grid: EnergyGrid
@export var health_manager: HealthManager
@export var score_manager: ScoreManager

@onready var health_bar: HealthBar = %HealthBar
@onready var energy_makeup_gauge: EnergyMakeupGauge = %EnergyMakeupGauge
@onready var frequency_gauge: FrequencyGauge = %FrequencyGauge
@onready var balance_lbl: Label = %BalanceLbl
@onready var score_label: Score = %ScoreLabel

var _update_timer: Timer


func _ready() -> void:
	_update_timer = Timer.new()
	_update_timer.wait_time = update_interval_ms / 1000.0
	_update_timer.timeout.connect(_update_energy_makeup_gauge)
	add_child(_update_timer)
	_update_timer.start()
	
	frequency_gauge.frequency_max_deviation = energy_grid.frequency_max_deviation_hz
	frequency_gauge.gauge_range_hz = 0.5


func _process(_delta: float) -> void:
	var frequency_hz: float = energy_grid.get_frequency_hz()
	var frequency_diff_hz: float = absf(frequency_hz - energy_grid.target_frequency_hz)
	var gauge_min_hz: float = energy_grid.target_frequency_hz - frequency_gauge.gauge_range_hz
	var gauge_max_hz: float = energy_grid.target_frequency_hz + frequency_gauge.gauge_range_hz
	var is_imbalanced: bool = frequency_diff_hz > energy_grid.frequency_max_deviation_hz
	
	#frequency_lbl.text = str(str(frequency_hz).pad_decimals(2), " Hz")
	frequency_gauge.current_frequency_hz = clampf(frequency_hz, gauge_min_hz, gauge_max_hz)
	
	if is_imbalanced:
		if Time.get_ticks_msec() % 1000 > 500:
			frequency_gauge.background_color = BAD_COLOR
		else:
			frequency_gauge.background_color = DEFAULT_COLOR
		
		if frequency_hz > 50:
			balance_lbl.text = "Oversupply"
		else:
			balance_lbl.text = "Undersupply"
	else:
		score_label.score = score_manager.score
		frequency_gauge.background_color = DEFAULT_COLOR
		balance_lbl.text = "Balanced"
	
	health_bar.health = health_manager.health


func _update_energy_makeup_gauge() -> void:
	energy_makeup_gauge.fossil = energy_grid.fossil
	energy_makeup_gauge.wind = energy_grid.wind
	energy_makeup_gauge.solar = energy_grid.solar
	energy_makeup_gauge.battery = energy_grid.battery_discharge
	energy_makeup_gauge.demand = energy_grid.demand
	energy_makeup_gauge.supply = energy_grid.supply
