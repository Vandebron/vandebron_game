extends Control
class_name Gauge
## Generic UI bar to represent both the active and potential state of things, like wind/solar/energy

@export var current: float:
	set(value):
		current = value
		(%GaugeBar.material as ShaderMaterial)\
			.set_shader_parameter("current", current)

@export var target: float:
	set(value):
		target = value
		(%GaugeBar.material as ShaderMaterial)\
			.set_shader_parameter("target", target)

@export var max_value: float:
	set(value):
		max_value = value
		(%GaugeBar.material as ShaderMaterial)\
			.set_shader_parameter("max_value", max_value)

@export var left_color: Color:
	set(value):
		left_color = value
		(%GaugeBar.material as ShaderMaterial)\
			.set_shader_parameter("left_color", left_color)

@export var right_color: Color:
	set(value):
		right_color = value
		(%GaugeBar.material as ShaderMaterial)\
			.set_shader_parameter("right_color", right_color)
