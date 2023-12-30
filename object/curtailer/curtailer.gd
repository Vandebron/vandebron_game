extends Node3D
class_name Curtailer

signal done

enum Mode {DISABLE, ENABLE}

@export var mode: Mode = Mode.DISABLE
@export var radius: float = 2.0: set=_set_radius
@export var camera: Camera3D

@onready var shape_indicator: MeshInstance3D = $ShapeIndicator
@onready var collider: Area3D = $Collider

var _pointer_pos: Vector3


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("build_confirm"):
		confirm()


func _process(delta: float) -> void:
	_pointer_pos = InputUtil.get_pointer_world_position(camera)
	var shape_pos: Vector3 = shape_indicator.global_position.lerp(_pointer_pos, delta * 15.0)
	
	shape_indicator.global_position.x = shape_pos.x
	shape_indicator.global_position.z = shape_pos.z
	collider.global_position = _pointer_pos


func _input(event: InputEvent) -> void:
	if event.is_action_released("build_cancel"):
		cancel()


func confirm() -> void:
	for area: Area3D in collider.get_overlapping_areas():
		var node: Node3D = area.owner
		if node is Producer:
			match mode:
				Curtailer.Mode.DISABLE:
					if !node.disabled:
						node.disable()
				Curtailer.Mode.ENABLE:
					if node.disabled:
						node.enable()


func cancel() -> void:
	done.emit()
	queue_free()


func _set_radius(value: float) -> void:
	radius = value
	
	$ShapeIndicator.mesh.top_radius = radius
	$ShapeIndicator.mesh.bottom_radius = radius
	
	$Collider/CollisionShape3D.shape.radius = radius
