extends Node3D

@export var sun_color_range: GradientTexture1D
@export var sun_light_energy_range: Curve
@export var weather: Weather

@onready var sun: DirectionalLight3D = $Sun


func _physics_process(_delta: float) -> void:
	# TODO: Fix sun rotation. It should not "jump" to a new orientation at break of dawn
	rotation.z = -(PI * 0.5 * weather.point_of_day)
	rotation.y = (PI * 0.5 * weather.point_of_day)
	
	sun.look_at(Vector3.ZERO)
	
	sun.light_color = sun_color_range.gradient.sample(weather.point_of_day)
	sun.light_energy = sun_light_energy_range.sample(weather.point_of_day)
