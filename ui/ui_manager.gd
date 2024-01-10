extends Node
class_name UiManager

var BAD_COLOR: Color = Color.hex(0xb45252ff)
var DEFAULT_COLOR: Color = Color.hex(0x332b40ff)

@export var energy_grid: EnergyGrid
@export var health_manager: HealthManager

@onready var health_bar: HealthBar = %HealthBar
@onready var energy_makeup_gauge: EnergyMakeupGauge = %EnergyMakeupGauge
@onready var frequency_gauge: FrequencyGauge = %FrequencyGauge
@onready var frequency_lbl: Label = %FrequencyLbl


func _ready() -> void:
	frequency_gauge.frequency_max_deviation = energy_grid.frequency_max_deviation_hz
	frequency_gauge.gauge_range_hz = 0.5


func _process(_delta: float) -> void:
	var frequency_hz: float = energy_grid.get_frequency_hz()
	var frequency_diff_hz: float = absf(frequency_hz - energy_grid.target_frequency_hz)
	var gauge_min_hz: float = energy_grid.target_frequency_hz - frequency_gauge.gauge_range_hz
	var gauge_max_hz: float = energy_grid.target_frequency_hz + frequency_gauge.gauge_range_hz
	var is_imbalanced: bool = frequency_diff_hz > energy_grid.frequency_max_deviation_hz
	
	energy_makeup_gauge.fossil = energy_grid.fossil
	energy_makeup_gauge.wind = energy_grid.wind
	energy_makeup_gauge.solar = energy_grid.solar
	energy_makeup_gauge.demand = energy_grid.demand
	energy_makeup_gauge.supply = energy_grid.supply
	
	frequency_lbl.text = str(str(frequency_hz).pad_decimals(2), " Hz")
	frequency_gauge.current_frequency_hz = clampf(frequency_hz, gauge_min_hz, gauge_max_hz)
	
	if is_imbalanced:
		if Time.get_ticks_msec() % 1000 > 500:
			frequency_gauge.background_color = BAD_COLOR
		else:
			frequency_gauge.background_color = DEFAULT_COLOR
	else:
			frequency_gauge.background_color = DEFAULT_COLOR
	
	health_bar.health = health_manager.health
