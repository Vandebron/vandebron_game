extends Node
class_name UiManager

var BAD_COLOR: Color = Color.hex(0xb45252ff)
var DEFAULT_COLOR: Color = Color.hex(0x332b40ff)

@export var energy_grid: EnergyGrid
@export var health_manager: HealthManager

@onready var health_bar: HealthBar = %HealthBar
@onready var energy_makeup_gauge: EnergyMakeupGauge = %EnergyMakeupGauge
@onready var grid_balance_gauge: GridBalanceGauge = %GridBalanceGauge
@onready var hz_ctnr: ColorRect = %HzCtnr
@onready var hz_lbl: Label = %HzLbl


func _ready() -> void:
	grid_balance_gauge.frequency_max_deviation = energy_grid.frequency_max_deviation_hz
	grid_balance_gauge.gauge_range_hz = 0.5


func _process(_delta: float) -> void:
	var frequency_hz: float = energy_grid.get_frequency_hz()
	var frequency_diff_hz: float = absf(frequency_hz - energy_grid.target_frequency_hz)
	var gauge_min_hz: float = energy_grid.target_frequency_hz - grid_balance_gauge.gauge_range_hz
	var is_imbalanced: bool = frequency_diff_hz > energy_grid.frequency_max_deviation_hz
	
	var hz_pip_position: float = clampf(frequency_hz - 1.0 * gauge_min_hz, 0.0, 1.0)
	hz_pip_position = hz_pip_position * grid_balance_gauge.size.x - (hz_ctnr.size.x / 2)
	
	hz_lbl.text = str(str(frequency_hz).pad_decimals(2), " Hz")
	hz_ctnr.position.x = hz_pip_position
	if is_imbalanced:
		if Time.get_ticks_msec() % 1000 > 500:
			hz_ctnr.color = BAD_COLOR
		else:
			hz_ctnr.color = DEFAULT_COLOR
	
	energy_makeup_gauge.fossil = energy_grid.fossil
	energy_makeup_gauge.wind = energy_grid.wind
	energy_makeup_gauge.solar = energy_grid.solar
	energy_makeup_gauge.demand = energy_grid.demand
	energy_makeup_gauge.supply = energy_grid.supply
	
	grid_balance_gauge.current_frequency_hz = frequency_hz
	
	health_bar.health = health_manager.health


func _precision2(x: float) -> String:
	return str(x).pad_decimals(2)
