class_name AutoBuildManager extends Node
@onready var energy_grid: EnergyGrid = $"../EnergyGrid"

const AUTO_BUILDER = preload("res://object/builder/auto_builder.tscn")
@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D
@export var build_manager: BuildManager
@export var house: BuildingDef
@onready var timer: Timer = $Timer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func calcualate_center_of_mass(positions: Array[Vector3]) -> Vector3:
	var result = Vector3.ZERO
	for p in positions:
		result += p
	return result / positions.size() 
	
	

func _on_timer_timeout() -> void:
	var builder: Builder = AUTO_BUILDER.instantiate()
	builder.building = house
	add_child(builder)
	builder.build_done.connect(_on_build_done)
	var mass = calcualate_center_of_mass(energy_grid.get_consumers_positions())
	builder.plot_building(mass, energy_grid.get_all_positions(), shape_cast_3d)

func _on_build_done(node: Node3D, building: BuildingDef, at_position: Vector3) -> void:
	energy_grid.add_building(node, at_position)
