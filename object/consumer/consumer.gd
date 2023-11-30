extends Node3D
class_name Consumer

@export var demand: float

@onready var house_model: Model = $HouseModel


func _init() -> void:
	add_to_group(Constants.GROUP_CONSUMER)


func _ready() -> void:
	house_model.animation_player.play("consume")
