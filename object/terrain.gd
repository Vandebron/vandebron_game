extends MeshInstance3D

var terrain_material: ShaderMaterial
var grid_material: ShaderMaterial


func _ready() -> void:
	terrain_material = get_surface_override_material(0) as ShaderMaterial
	
	grid_material = get_surface_override_material(0).next_pass as ShaderMaterial
	grid_material.set_shader_parameter("cell_size", Constants.GRID_CELL_SIZE.x)
	
	Events.season_started.connect(self._on_season_started)
	Events.season_ended.connect(self._on_season_ended)
	
	_on_season_started(weather.season)


func _process(_delta: float) -> void:
	var pointer_pos: Vector3 = InputUtil.pointer_world_pos
	grid_material.set_shader_parameter("pointer_world_pos", pointer_pos)


func _on_season_started(season: Weather.Season) -> void:
	match season:
		Weather.Season.AUTUMN:
			_set_ground_color(Color.hex(0xd3a068ff))
		Weather.Season.WINTER:
			_set_snow_density(0.65)
			_set_ground_color(Color.hex(0xa77b5bff))
		Weather.Season.SPRING:
			_set_ground_color(Color.hex(0xc2d368ff))
		Weather.Season.SUMMER:
			_set_ground_color(Color.hex(0x8ab060ff))


func _on_season_ended(season: Weather.Season) -> void:
	match season:
		Weather.Season.WINTER:
			_set_snow_density(0.0)


func _set_ground_color(color: Color) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(terrain_material, "shader_parameter/ground_color", color, 2.0)


func _set_snow_density(density: float) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(terrain_material, "shader_parameter/snow_density", density, 2.0)
