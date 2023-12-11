extends Control
class_name Gauge
## Generic UI bar to represent both the active and potential state of things, like wind/solar/energy

@export var current: float = 0.2 :
	set(value):
		current = value
		$Pip.position.x = ((current / max_value) * size.x * scale.x) - $Pip.size.x / 2.0
		(material as ShaderMaterial).set_shader_parameter("current", current)

@export var target: float = 0.7 :
	set(value):
		target = value
		(material as ShaderMaterial).set_shader_parameter("target", target)

@export var max_value: float = 1.0 :
	set(value):
		max_value = value
		(material as ShaderMaterial).set_shader_parameter("max_value", max_value)

@export var left_color: Color:
	set(value):
		left_color = value
		(material as ShaderMaterial).set_shader_parameter("left_color", left_color)

@export var right_color: Color:
	set(value):
		right_color = value
		(material as ShaderMaterial).set_shader_parameter("right_color", right_color)
