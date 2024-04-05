extends Control
class_name EnergyMakeupGauge

@export var fossil: float:
	set(value):
		fossil = value
		%Gauge.material.set_shader_parameter("fossil", fossil)

@export var solar: float:
	set(value):
		solar = value
		%Gauge.material.set_shader_parameter("solar", solar)

@export var wind: float:
	set(value):
		wind = value
		%Gauge.material.set_shader_parameter("wind", wind)

@export var battery: float:
	set(value):
		battery = value
		%Gauge.material.set_shader_parameter("battery", battery)

@export var demand: float:
	set(value):
		demand = value
		%Gauge.material.set_shader_parameter("demand", demand)
		%DemandLbl.text = str(str(demand).pad_decimals(2), " kW")

@export var supply: float:
	set(value):
		supply = value
		%SupplyLbl.text = str(str(supply).pad_decimals(2), " kW")
