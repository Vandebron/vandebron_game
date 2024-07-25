class_name SunManager extends Node3D

@export var clock: Clock: set=set_clock
@export var dawn_color: Color = Color.WHITE
@export var noon_color: Color = Color.WHITE
@export var dusk_color: Color = Color.WHITE
@export var night_color: Color = Color.WHITE

@onready var sun: DirectionalLight3D = $Sun


func set_clock(clock: Clock) -> void:
	clock.part_of_day_started.connect(set_part_of_day)


func set_part_of_day(part_of_day: Clock.DayPart) -> void:
	var color: Color
	var energy: float
	var rotation_y: float
	var rotation_z: float
	
	match part_of_day:
		Clock.DayPart.DAWN:
			color = dawn_color
			energy = 1.0
			rotation_y = 0.1 * PI
			rotation_z = -0.1 * PI
		Clock.DayPart.NOON:
			color = noon_color
			energy = 0.9
			rotation_y = 0.3 * PI
			rotation_z = -0.3 * PI
		Clock.DayPart.DUSK:
			color = dusk_color
			energy = 0.8
			rotation_y = 0.45 * PI
			rotation_z = -0.45 * PI
		Clock.DayPart.NIGHT:
			color = night_color
			energy = 0.2
			rotation_y = 0.55 * PI
			rotation_z = -0.55 * PI
	
	const duration: float = 1.0
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sun, "light_color", color, duration)
	tween.parallel().tween_property(sun, "light_energy", energy, duration)
	tween.parallel().tween_property(self, "rotation:y", rotation_y, duration)
	tween.parallel().tween_property(self, "rotation:z", rotation_z, duration)
	tween.tween_callback(func(): sun.look_at(Vector3.ZERO))
