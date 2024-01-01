extends Node3D

const tree_wood_material: ShaderMaterial = preload("res://object/tree/tree_wood_material.tres")
const tree_leaves_material: ShaderMaterial = preload("res://object/tree/tree_leaves_material.tres")

@export var terrain: MeshInstance3D
@export var clock: Clock
@export var weather: Weather

var terrain_material: ShaderMaterial
var grid_material: ShaderMaterial


func _ready() -> void:
	terrain_material = terrain.get_surface_override_material(0) as ShaderMaterial
	
	grid_material = terrain.get_surface_override_material(0).next_pass as ShaderMaterial
	grid_material.set_shader_parameter("cell_size", Constants.GRID_CELL_SIZE.x)
	
	clock.season_started.connect(_on_season_started)
	clock.season_ended.connect(_on_season_ended)
	
	_on_season_started(clock.season)


func _process(_delta: float) -> void:
	tree_wood_material.set_shader_parameter("sway_radius", weather.wind * 0.1)
	tree_leaves_material.set_shader_parameter("sway_radius", weather.wind * 0.1)


func _on_season_started(season: Clock.Season) -> void:
	match season:
		Clock.Season.AUTUMN:
			_set_ground_color(Color.hex(0xd3a068ff))
			tree_leaves_material.set_shader_parameter("albedo", Color.hex(0xa77b5bff))
		Clock.Season.WINTER:
			_set_snow_density(0.65)
			_set_ground_color(Color.hex(0xa77b5bff))
			_set_tree_leaves_transparency(1.0)
		Clock.Season.SPRING:
			tree_leaves_material.set_shader_parameter("albedo", Color.hex(0x8ab060ff))
			_set_ground_color(Color.hex(0xc2d368ff))
		Clock.Season.SUMMER:
			_set_ground_color(Color.hex(0x8ab060ff))


func _on_season_ended(season: Clock.Season) -> void:
	match season:
		Clock.Season.WINTER:
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
