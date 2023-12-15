extends Node3D

@export var cloud_scene: PackedScene


func _on_spawn_cloud_timeout():
	var cloud = cloud_scene.instantiate()
	
	var cloud_spawn_location: PathFollow3D = get_node("SpawnPath/SpawnLocation")
	
	# And give it a random offset.
	cloud_spawn_location.progress_ratio = randf()
	cloud.position = cloud_spawn_location.position
	add_child(cloud)
