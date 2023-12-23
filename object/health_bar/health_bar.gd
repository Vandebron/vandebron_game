extends PanelContainer
class_name HealthBar

@export var health: float = 50.0:
	set(value):
		health = value
		%HealthBar.value = health
