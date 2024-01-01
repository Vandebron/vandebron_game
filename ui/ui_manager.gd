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
	grid_balance_gauge.frequency_max_deviation = _get_normalized_frequency_max_deviation()


func _process(_delta: float) -> void:
	supply_lbl.text = str(_precision2(energy_grid.supply), " kW")
	demand_lbl.text = str(_precision2(energy_grid.demand), " kW")
	
	hz_lbl.text = str(_precision2(_get_frequency_hz()), " Hz")
	hz_ctnr.position.x = (energy_grid.balance * grid_balance_gauge.size.x) - (hz_ctnr.size.x / 2)
	
	grid_balance_gauge.fossil = energy_grid.fossil
	grid_balance_gauge.wind = energy_grid.wind
	grid_balance_gauge.solar = energy_grid.solar
	grid_balance_gauge.demand = energy_grid.demand
	grid_balance_gauge.balance = energy_grid.balance
	
	health_bar.health = health_manager.health


func _get_normalized_frequency_max_deviation() -> float:
	return energy_grid.frequency_max_deviation_hz / energy_grid.target_frequency_hz


func _get_frequency_hz() -> float:
	return energy_grid.balance * energy_grid.target_frequency_hz * 2.0


func _precision2(x: float) -> String:
	return str(x).pad_decimals(2)
