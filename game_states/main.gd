extends Node3D

const DEFAULT_GAME_PATH: String = "res://game_states/default_game/default_game.tscn"
const MAIN_MENU_PATH: String = "res://game_states/main_menu/main_menu.tscn"

const PHYSICS_TICKS_ACCEPTABLE_DEVIATION: float = 0.002

@onready var popup_canvas_layer: CanvasLayer = $PopupCanvasLayer
@onready var game_over_popup: PanelContainer = %GameOverPopup
@onready var pause_popup: PanelContainer = %PausePopup
@onready var spinner: ColorRect = %Spinner
@onready var loading_screen: Control = $LoadingScreen
@onready var resume_button: Button = %ResumeButton

var _spinner_tween: Tween
var _game: Game
var _main_menu: MainMenu: set=_set_main_menu
var _main_menu_scn: PackedScene
var _game_scn: PackedScene

var _dynamic_resolution_scaling: bool

# Physics tick counting, to determine performance stability
var _ticks_per_second: int
var _tick_deltas: PackedFloat32Array
var _tick_delta_target: float


func _ready() -> void:
	game_over_popup.quit_to_menu.connect(_quit_to_menu)
	game_over_popup.restart.connect(_start_game)
	_start_loading_main_menu(func(): 
		_main_menu_scn = (ResourceLoader.load_threaded_get(MAIN_MENU_PATH) as PackedScene)
		_reload_main_menu())
	
	resume_button.pressed.connect(_toggle_pause)
	
	_ticks_per_second = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
	_tick_delta_target = (1.0 / _ticks_per_second) + PHYSICS_TICKS_ACCEPTABLE_DEVIATION
	
	_tick_deltas = PackedFloat32Array()
	_tick_deltas.resize(_ticks_per_second)
	_tick_deltas.fill(1000.0)
	
	ProjectSettings.settings_changed.connect(_on_settings_changed)


func _physics_process(delta: float) -> void:
	var tick: int = wrapi(Engine.get_physics_frames(), 0, _ticks_per_second)
	_tick_deltas.set(tick, delta)


func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel") && _game && !_game.is_game_over:
		_toggle_pause()


func _toggle_pause() -> void:
	_game.get_tree().paused = !_game.get_tree().paused
	popup_canvas_layer.visible = !popup_canvas_layer.visible
	pause_popup.visible = !pause_popup.visible


func _quit_to_menu() -> void:
	if _game:
		_game.queue_free()
		_game = null
	
	_reload_main_menu()
	
	popup_canvas_layer.hide()
	game_over_popup.hide()


func _on_game_over() -> void:
	_game.is_game_over = true
	_game.get_tree().paused = true
	popup_canvas_layer.show()
	game_over_popup.show()


func _reload_main_menu() -> void:
	_main_menu = _main_menu_scn.instantiate()
	_main_menu.show()
	add_child(_main_menu)
	loading_screen.hide()


func _set_main_menu(value: MainMenu) -> void:
	_main_menu = value
	if _main_menu:
		_main_menu.game_started.connect(func():
			_start_loading_default_game(func():
				_game_scn = (ResourceLoader.load_threaded_get(DEFAULT_GAME_PATH) as PackedScene)
				_start_game()
			))


func _start_game() -> void:
	if _game:
		_game.queue_free()
	if _main_menu:
		_main_menu.queue_free()
		_main_menu = null
	
	_game = _game_scn.instantiate()
	_game.game_over.connect(_on_game_over)
	_game.pause_please.connect(_toggle_pause)
	add_child(_game)
	popup_canvas_layer.hide()

	loading_screen.hide()
	_spinner_tween.kill()
	print_verbose("%d - loading finished" % [Time.get_ticks_msec()])
	
	call_deferred_thread_group("_wait_for_stable_frame_rate", func(): _game.get_tree().paused = false)


func _start_loading_default_game(callback: Callable) -> void:
	print_verbose(Time.get_ticks_msec(), " loading started")
	call_deferred_thread_group("_start_async_loading", DEFAULT_GAME_PATH, callback)


func _start_loading_main_menu(callback: Callable) -> void:
	print_verbose(Time.get_ticks_msec(), " loading started")
	call_deferred_thread_group("_start_async_loading", MAIN_MENU_PATH, callback)


func _start_async_loading(path_to_load: String, callback: Callable) -> void:
	_spinner_tween = create_tween()
	_spinner_tween.set_loops()
	_spinner_tween.set_ease(Tween.EASE_IN)
	_spinner_tween.set_trans(Tween.TRANS_BACK)
	_spinner_tween.tween_property(spinner, "rotation", PI, 1.0).from(0.0)
	_spinner_tween.tween_property(spinner, "rotation", PI, 0.0)
	
	loading_screen.show()
	_wait_for_async_loads([path_to_load], callback)


func _wait_for_async_loads(paths: Array[String], callback: Callable) -> void:
	print_verbose("%d - start loading resources" % [Time.get_ticks_msec()])
	var type_hint := ""
	var use_sub_threads := false # Sub threads don't work anymore for some reason
	var progress: Array[int] = []
	for path: String in paths:
		# NOTE: load_threaded_request() HAS to be called 1-by-1, i.e. you have to wait until
		#		it fully loads by checking load_threaded_get_status(). Otherwise you WILL often get
		#		get into an unrecoverable fail state, because multiple resources tried to load
		#		the same shared resource concurrently.
		ResourceLoader.load_threaded_request(path, type_hint, use_sub_threads)
		var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(path, progress)
		print_verbose("%d - %4.2f%% status=%d %s" % [Time.get_ticks_msec(), progress[0], status, path])
		while status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			await get_tree().create_timer(0.1).timeout
			status = ResourceLoader.load_threaded_get_status(path, progress)
			print_verbose("%d - %4.2f%% status=%d %s" % [Time.get_ticks_msec(), progress[0], status, path])
	print_verbose("%d - all resources loaded (regardless of error)" % [Time.get_ticks_msec()])
	callback.call()


## CAUTION: Always call this using call_deferred_thread_group(), since it uses a blocking while loop.
func _wait_for_stable_frame_rate(callback: Callable) -> void:
	print_verbose(Time.get_ticks_msec(), " waiting for stable frame rate")
	
	const max_wait_msec: int = 5000
	var start_time_msec: int = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time_msec < max_wait_msec:
		await get_tree().create_timer(0.1).timeout
		
		# TODO: Calculate standard deviation (stdev) or mean instead of average for better accuracy
		var average_frame_time: float = 0.0
		for delta: float in _tick_deltas:
			average_frame_time += delta
		
		average_frame_time = average_frame_time / _tick_deltas.size()
		if average_frame_time < _tick_delta_target:
			print_verbose(Time.get_ticks_msec(), " average_frame_time ", average_frame_time, " is ok")
			callback.call()
			break
		else:
			print_verbose(Time.get_ticks_msec(), " average_frame_time ", average_frame_time, " is not stable")
	callback.call()


## CAUTION: Always call this using call_deferred_thread_group(), since it uses a blocking while loop.
func _do_dynamic_resolution_scaling() -> void:
	print_verbose("Starting dynamic resolution scaling")
	while _dynamic_resolution_scaling:
		await get_tree().create_timer(0.1).timeout
		
		# TODO: Calculate standard deviation (stdev) or mean instead of average for better accuracy
		var average_frame_time: float = 0.0
		for delta: float in _tick_deltas:
			average_frame_time += delta
		
		average_frame_time = average_frame_time / _tick_deltas.size()
		if average_frame_time < _tick_delta_target:
			#print_verbose(Time.get_ticks_msec(), " average_frame_time ", average_frame_time, " is ok")
			get_viewport().scaling_3d_scale = 1.0
		else:
			#print_verbose(Time.get_ticks_msec(), " average_frame_time ", average_frame_time, " is not stable")
			get_viewport().scaling_3d_scale = 0.1


func _on_settings_changed() -> void:
	_dynamic_resolution_scaling = ProjectSettings.get_setting("rendering/scaling_3d/dynamic_scaling", false)
	if _dynamic_resolution_scaling:
		call_deferred_thread_group("_do_dynamic_resolution_scaling")
