extends Node3D

@export var cloud_scenes: Array[PackedScene]

@onready var cloud_spawn_location: PathFollow3D = $SpawnPath/SpawnLocation

func _ready() -> void:
	_on_spawn_cloud_timeout()

func _on_spawn_cloud_timeout() -> void:
	var random_index: int = randi_range(0, cloud_scenes.size() - 1)
	var cloud: Cloud = cloud_scenes[random_index].instantiate()
	
	# And give it a random offset.
	cloud_spawn_location.progress_ratio = randf()
	cloud.position = cloud_spawn_location.position
	cloud.max_distance = 32.0
	add_child(cloud)
