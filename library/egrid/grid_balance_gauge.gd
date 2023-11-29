extends ColorRect


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
