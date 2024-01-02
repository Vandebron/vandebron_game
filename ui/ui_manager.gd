extends Node
class_name UiManager

@export var energy_grid: EnergyGrid
@export var health_manager: HealthManager

@onready var health_bar: HealthBar = %HealthBar
@onready var supply_lbl: Label = %SupplyLbl
@onready var demand_lbl: Label = %DemandLbl
@onready var grid_balance_gauge: GridBalanceGauge = %GridBalanceGauge
@onready var hz_ctnr: ColorRect = %HzCtnr
@onready var hz_lbl: Label = %HzLbl


func _ready() -> void:
	grid_balance_gauge.frequency_max_deviation = energy_grid.frequency_max_deviation_hz
	grid_balance_gauge.gauge_range_hz = 0.5


func _process(_delta: float) -> void:
	var frequency_hz: float = energy_grid.get_frequency_hz()
	var gauge_min_hz: float = energy_grid.target_frequency_hz - grid_balance_gauge.gauge_range_hz
	
	var hz_pip_position: float = clampf(frequency_hz - 1.0 * gauge_min_hz, 0.0, 1.0)
	hz_pip_position = hz_pip_position * grid_balance_gauge.size.x - (hz_ctnr.size.x / 2)
	
	supply_lbl.text = str(_precision2(energy_grid.supply), " kW")
	demand_lbl.text = str(_precision2(energy_grid.demand), " kW")
	
	hz_lbl.text = str(_precision2(frequency_hz), " Hz")
	hz_ctnr.position.x = hz_pip_position
	
	grid_balance_gauge.fossil = energy_grid.fossil
	grid_balance_gauge.wind = energy_grid.wind
	grid_balance_gauge.solar = energy_grid.solar
	grid_balance_gauge.demand = energy_grid.demand
	grid_balance_gauge.current_frequency_hz = frequency_hz
	
	health_bar.health = health_manager.health


func _precision2(x: float) -> String:
	return str(x).pad_decimals(2)
