extends Node3D

#Have wind speed affect this
var speed = 5  # Adjust the speed as needed
# Called when the node enters the scene tree for the first time.
func _ready():
	print("hello") # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(Vector3.RIGHT * speed * delta)
