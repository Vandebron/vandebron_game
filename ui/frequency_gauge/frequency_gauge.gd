class_name FrequencyGauge extends ColorRect

@export var background_color: Color:
	set(value):
		background_color = value
		(material as ShaderMaterial).set_shader_parameter("background_color", background_color)

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
