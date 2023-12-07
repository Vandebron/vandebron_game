extends ColorRect
class_name GridBalanceGauge


@export var supply: float:
	set(value):
		supply = value
		(material as ShaderMaterial).set_shader_parameter("supply", supply)

@export var demand: float:
	set(value):
		demand = value
		(material as ShaderMaterial).set_shader_parameter("demand", demand)

@export var balance: float:
	set(value):
		balance = value
		(material as ShaderMaterial).set_shader_parameter("balance", balance)

@export var frequency_tolerance: float:
	set(value):
		frequency_tolerance = value
		(material as ShaderMaterial).set_shader_parameter("freq_margin", frequency_tolerance)
