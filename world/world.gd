extends Node3D

const tree_wood_material: ShaderMaterial = preload("res://object/tree/tree_wood_material.tres")
const tree_leaves_material: ShaderMaterial = preload("res://object/tree/tree_leaves_material.tres")

# TODO: Crosshair should probably be on CameraAnchor, but I'm lazy
@onready var crosshair: MeshInstance3D = %Crosshair
@onready var terrain: MeshInstance3D = %Terrain

var terrain_material: ShaderMaterial
var grid_material: ShaderMaterial


func _ready() -> void:
	terrain_material = terrain.get_surface_override_material(0) as ShaderMaterial
	
	grid_material = terrain.get_surface_override_material(0).next_pass as ShaderMaterial
	grid_material.set_shader_parameter("cell_size", Constants.GRID_CELL_SIZE.x)
	
	Events.season_started.connect(self._on_season_started)
	Events.season_ended.connect(self._on_season_ended)
	
	_on_season_started(Weather.season)


func _process(_delta: float) -> void:
	var pointer_pos: Vector3 = InputUtil.pointer_world_pos
	grid_material.set_shader_parameter("pointer_world_pos", pointer_pos)
	crosshair.global_position = pointer_pos


func _physics_process(_delta: float) -> void:
	tree_wood_material.set_shader_parameter("sway_radius", Weather.wind * 0.1)
	tree_leaves_material.set_shader_parameter("sway_radius", Weather.wind * 0.1)


func _on_season_started(season: Weather.Season) -> void:
	match season:
		Weather.Season.AUTUMN:
			_set_ground_color(Color.hex(0xd3a068ff))
			tree_leaves_material.set_shader_parameter("albedo", Color.hex(0xa77b5bff))
		Weather.Season.WINTER:
			_set_snow_density(0.65)
			_set_ground_color(Color.hex(0xa77b5bff))
			_set_tree_leaves_transparency(1.0)
		Weather.Season.SPRING:
			tree_leaves_material.set_shader_parameter("albedo", Color.hex(0x8ab060ff))
			_set_ground_color(Color.hex(0xc2d368ff))
		Weather.Season.SUMMER:
			_set_ground_color(Color.hex(0x8ab060ff))


func _on_season_ended(season: Weather.Season) -> void:
	match season:
		Weather.Season.WINTER:
			_set_snow_density(0.0)
			_set_tree_leaves_transparency(0.0)


func _set_ground_color(color: Color) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(terrain_material, "shader_parameter/ground_color", color, 2.0)


func _set_snow_density(density: float) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(terrain_material, "shader_parameter/snow_density", density, 2.0)


func _set_tree_leaves_transparency(transparency: float) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(tree_leaves_material, "shader_parameter/transparency", transparency, 2.0)
