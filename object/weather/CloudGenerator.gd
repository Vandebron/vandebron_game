extends Node3D

@export var cloud_scene: PackedScene
@onready var cloud_spawn_location: PathFollow3D = $SpawnPath/SpawnLocation

func _on_spawn_cloud_timeout() -> void:
	var cloud = cloud_scene.instantiate()
	
	# And give it a random offset.
	cloud_spawn_location.progress_ratio = randf()
	cloud.position = cloud_spawn_location.position
	add_child(cloud)
