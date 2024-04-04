class_name AutoBuildManager extends Node

@export var build_manager: BuildManager
@export var house: BuildingDef
@onready var timer: Timer = $Timer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:

	#build_manager.auto_create_builder(house)
	build_manager.auto_confirm()
