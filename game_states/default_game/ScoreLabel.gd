class_name Budget extends Label


@export var budget: int = 0:
	set(value):
		budget = value
		text = "Budget: " + str(value)
