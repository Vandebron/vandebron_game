extends Node3D

const curtailer_scn: PackedScene = preload("res://object/curtailer/curtailer.tscn")

@export var manage_menu: ItemList
@export var camera: Camera3D


func _ready() -> void:
	Events.builder_initiated.connect(_cancel_all)
	manage_menu.item_selected.connect(_on_action_selected)


func _on_action_selected(index: int) -> void:
	Events.curtailer_initiated.emit()
	
	_cancel_all()
	
	var curtailer: Curtailer = curtailer_scn.instantiate()
	curtailer.camera = camera
	curtailer.done.connect(_on_curtailment_done)
	
	var action_text: String = manage_menu.get_item_text(index)
	
	match action_text:
		"Enable":
			curtailer.mode = Curtailer.Mode.ENABLE
		"Disable":
			curtailer.mode = Curtailer.Mode.DISABLE
	
	add_child(curtailer)


func _cancel_all() -> void:
	for c: Curtailer in get_children():
		c.cancel()


func _on_curtailment_done() -> void:
	pass
