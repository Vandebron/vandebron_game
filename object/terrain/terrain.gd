class_name Terrain extends MeshInstance3D

const TREE_WOOD_MAT: ShaderMaterial = preload("res://object/tree/tree_wood_material.tres")
const TREE_LEAVES_MAT: ShaderMaterial = preload("res://object/tree/tree_leaves_material.tres")
const TREE_UPDATE_INTERVAL_SEC: float = 0.5

@export var clock: Clock
@export var weather: Weather

@onready var grid_material: ShaderMaterial = get_surface_override_material(0).next_pass as ShaderMaterial
@onready var terrain_material: ShaderMaterial = get_surface_override_material(0) as ShaderMaterial

var _camera: Camera3D


func _ready() -> void:
	_camera = get_viewport().get_camera_3d()
	
	#grid_material.set_shader_parameter("cell_size", Constants.GRID_CELL_SIZE.x)
	
	clock.season_started.connect(_on_season_started)
	clock.season_ended.connect(_on_season_ended)
	
	_on_season_started(clock.season)
	_update_tree_sway()


func _process(_delta: float) -> void:
	var pointer_world_pos: Vector3 = InputUtil.get_pointer_world_position(_camera)
	#grid_material.set_shader_parameter("pointer_world_pos", pointer_world_pos)


func _on_season_started(season: Clock.Season) -> void:
	match season:
		Clock.Season.AUTUMN:
			var color := Color.hex(0xd3a068ff)
			_set_main_color(color)
			_set_secondary_color(color.darkened(0.1))
			_set_splatmap_edge(0.3)
			TREE_LEAVES_MAT.set_shader_parameter("albedo", Color.hex(0xa77b5bff))
		Clock.Season.WINTER:
			_set_main_color(Color.hex(0xa77b5bff))
			_set_secondary_color(Color.WHITE)
			_set_splatmap_edge(0.65)
			_set_tree_leaves_transparency(1.0)
		Clock.Season.SPRING:
			var color := Color.hex(0xc2d368ff)
			_set_main_color(Color.hex(0xc2d368ff))
			_set_secondary_color(color.darkened(0.1))
			_set_splatmap_edge(0.75)
			TREE_LEAVES_MAT.set_shader_parameter("albedo", Color.hex(0x8ab060ff))
		Clock.Season.SUMMER:
			var color := Color.hex(0xc2d368ff)
			_set_main_color(color)
			_set_secondary_color(color.darkened(0.1))
			_set_splatmap_edge(0.5)


func _on_season_ended(season: Clock.Season) -> void:
	match season:
		Clock.Season.WINTER:
			_set_tree_leaves_transparency(0.0)


func _set_main_color(color: Color) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(terrain_material, "shader_parameter/main_color", color, 2.0)


func _set_secondary_color(color: Color) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(terrain_material, "shader_parameter/second_color", color, 2.0)


func _set_splatmap_edge(density: float) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(terrain_material, "shader_parameter/edge", density, 2.0)


func _set_tree_leaves_transparency(transparency: float) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(TREE_LEAVES_MAT, "shader_parameter/transparency", transparency, 2.0)


func _update_tree_sway() -> void:
	get_tree().create_timer(TREE_UPDATE_INTERVAL_SEC).timeout.connect(_update_tree_sway)
	TREE_WOOD_MAT.set_shader_parameter("sway_radius", weather.wind * 0.1)
	TREE_LEAVES_MAT.set_shader_parameter("sway_radius", weather.wind * 0.1)
