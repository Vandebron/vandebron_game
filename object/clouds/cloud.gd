extends Node3D
class_name Cloud

#Have wind speed affect this
var speed: float = 5.0 # Adjust the speed as needed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	translate(Vector3.RIGHT * speed * delta)


func _on_deletion_timer_timeout():
	queue_free()
