class_name Win extends Label

@export var time: float = 0.0:
	set(value):
		time = value
		text = str(int(floor(time)))
