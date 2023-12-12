extends Node3D

@onready var sun: DirectionalLight3D = $Sun
@onready var moon: DirectionalLight3D = $Moon


func _physics_process(_delta: float) -> void:
	rotation.z = PI * (1.0 - Weather.point_of_day)
	rotation.y = PI * (1.0 - Weather.point_of_day)
	
	sun.visible = Weather.is_day()
	moon.visible = Weather.is_night()
	
	sun.look_at(Vector3.ZERO)
	moon.look_at(Vector3.ZERO)
	
	# TODO: Add dawn/dusk lighting style like this:
	#sun.light_color = Color.hex(0xd3a068ff)
	#sun.light_energy = 0.5
	#$WorldEnvironment.environment.fog_enabled = _is_night()
