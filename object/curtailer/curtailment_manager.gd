class_name CurtailmentManager extends Node3D

const curtailer_scn: PackedScene = preload("res://object/curtailer/curtailer.tscn")

@export var menu: AssetMgmtMenu


func _ready() -> void:
	Events.builder_initiated.connect(_cancel_all)
	menu.enable_action_pressed.connect(start_curtailer.bind(Curtailer.Mode.ENABLE))
	menu.disable_action_pressed.connect(start_curtailer.bind(Curtailer.Mode.DISABLE))


func start_curtailer(mode: Curtailer.Mode) -> void:
	Events.curtailer_initiated.emit()
	_cancel_all()
	
	var curtailer: Curtailer = curtailer_scn.instantiate()
	curtailer.done.connect(_on_curtailment_done)
	curtailer.mode = mode
	add_child(curtailer)


func _cancel_all() -> void:
	for c: Curtailer in get_children():
		c.cancel()


func _on_curtailment_done() -> void:
	pass
