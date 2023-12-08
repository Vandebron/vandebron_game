extends ColorRect
class_name GridBalanceGauge

@export var fossil: float:
	set(value):
		fossil = value
		(material as ShaderMaterial).set_shader_parameter("fossil", fossil)

@export var solar: float:
	set(value):
		solar = value
		(material as ShaderMaterial).set_shader_parameter("solar", solar)

@export var wind: float:
	set(value):
		wind = value
		(material as ShaderMaterial).set_shader_parameter("wind", wind)

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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("show_info"):
		(material as ShaderMaterial).set_shader_parameter("show_details", true)
	elif event.is_action_released("show_info"):
		(material as ShaderMaterial).set_shader_parameter("show_details", false)
