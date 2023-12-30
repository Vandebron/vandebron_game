extends Node3D
class_name BuildShapeIndicator

var GOOD_COLOR := Color.hex(0x8ab060ff)
var BAD_COLOR := Color.hex(0xb45252ff)

@export var ignore_visibility: bool
@export var collider: Area3D: set=_set_collider
@export var mesh_nodes: Array[MeshInstance3D]: set=_set_mesh_nodes

var highlight_material: StandardMaterial3D = preload("res://object/builder/highlight_material.tres")


# TODO: Something in this whole class is broken; things are randomly using GOOD_COLOR sometimes
#func _physics_process(_delta: float) -> void:
	#if collider.has_overlapping_areas():
		#set_bad()
	#else:
		#set_good()


func set_good() -> void:
	highlight_material.albedo_color = GOOD_COLOR


func set_bad() -> void:
	highlight_material.albedo_color = BAD_COLOR


func _on_collider_entered(_area: Area3D) -> void:
	if !ignore_visibility:
		show()
	set_bad()


func _on_collider_exited(_area: Area3D) -> void:
	if collider.has_overlapping_areas():
		return
	if !ignore_visibility:
		hide()
	set_good()


func _set_collider(value: Area3D) -> void:
	collider = value
	collider.area_entered.connect(_on_collider_entered)
	collider.area_exited.connect(_on_collider_exited)


func _set_mesh_nodes(value: Array[MeshInstance3D]) -> void:
	mesh_nodes = value
	
	for mesh: MeshInstance3D in mesh_nodes:
		mesh.set_surface_override_material(0, highlight_material)
	
	set_good()
