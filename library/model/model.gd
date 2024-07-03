class_name Model extends Node3D

@export var mesh_nodes: Array[MeshInstance3D] # TODO: Think of a less hacky way to get all meshes; traverse scene tree?
@export var animation_player: AnimationPlayer
