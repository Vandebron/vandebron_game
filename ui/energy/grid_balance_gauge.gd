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

@export var current_frequency_hz: float:
	set(value):
		current_frequency_hz = value
		(material as ShaderMaterial).set_shader_parameter("current_hz", current_frequency_hz)

@export var frequency_max_deviation: float:
	set(value):
		frequency_max_deviation = value
		(material as ShaderMaterial)\
			.set_shader_parameter("freq_max_deviation", frequency_max_deviation)

@export var gauge_range_hz: float:
	set(value):
		gauge_range_hz = value
		(material as ShaderMaterial).set_shader_parameter("gauge_range_hz", gauge_range_hz)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("show_info"):
		(material as ShaderMaterial).set_shader_parameter("show_details", true)
	elif event.is_action_released("show_info"):
		(material as ShaderMaterial).set_shader_parameter("show_details", false)
