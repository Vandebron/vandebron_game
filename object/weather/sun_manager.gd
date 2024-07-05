class_name SunManager extends Node3D

@export var sun_color_range: GradientTexture1D
@export var sun_light_energy_range: Curve
@export_range(0.0, 1.0, 0.01) var point_of_day: float = 0.5 : set=set_point_of_day

@onready var sun: DirectionalLight3D = $Sun


func set_point_of_day(value: float) -> void:
	point_of_day = value
	
	if !OS.has_feature("web"):
		# TODO: Fix sun rotation. It should not "jump" to a new orientation at break of dawn
		rotation.z = -(PI * 0.5 * point_of_day)
		rotation.y = (PI * 0.5 * point_of_day)
	
	sun.look_at(Vector3.ZERO)
	
	sun.light_color = sun_color_range.gradient.sample(point_of_day)
	sun.light_energy = sun_light_energy_range.sample(point_of_day)
