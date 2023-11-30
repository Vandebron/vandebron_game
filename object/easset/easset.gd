extends Node3D
class_name EAsset # E=Energy

@export var nominal_power: float = 10.0
@export var active_capability_out: float
@export var dmol: float = 0.0

@onready var model: Model = $Model

var current_power: float


func _init() -> void:
	add_to_group(Constants.GROUP_PRODUCER)


func _ready() -> void:
	model.animation_player.play("spin")


func _physics_process(_delta: float) -> void:
	current_power = nominal_power
