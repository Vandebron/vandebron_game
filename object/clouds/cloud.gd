extends Node3D
class_name Cloud

# TODO: Have wind speed affect this
@export var speed: float = 5.0 # Adjust the speed as needed
@export var max_distance: float = 10.0

var _distance_traveled: float


func _ready() -> void:
	scale = Vector3.ZERO


func _process(delta: float) -> void:
	var move_delta: float = speed * delta
	translate(Vector3.RIGHT * move_delta)
	
	scale = scale.lerp(Vector3.ONE, move_delta)
	
	_distance_traveled += move_delta
	if _distance_traveled > max_distance:
		queue_free()
