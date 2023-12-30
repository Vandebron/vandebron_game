extends Node3D
class_name Curtailer

signal done

enum Mode {DISABLE, ENABLE}

@export var camera: Camera3D
@export var mode: Mode

@onready var shape_indicator: MeshInstance3D = $ShapeIndicator
@onready var collider: Area3D = $Collider

var _pointer_pos: Vector3


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("build_confirm"):
		confirm()


func _process(delta: float) -> void:
	_pointer_pos = InputUtil.get_pointer_world_position(camera).snapped(Constants.GRID_CELL_SIZE)
	
	shape_indicator.global_position = shape_indicator.global_position.lerp(_pointer_pos, delta * 15.0)
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
