class_name Score extends Label


@export var score: int = 0:
	set(value):
		score = value
		text = Utils.decimal_with_separators(score)
