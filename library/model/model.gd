extends Node
class_name Model


func get_animation_player() -> AnimationPlayer:
	return get_node_or_null("AnimationPlayer")
