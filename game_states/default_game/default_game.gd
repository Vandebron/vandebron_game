extends Game

const CONTROLS_MESSAGE = preload("res://ui/message/controls_message.tscn")
const DEMAND_MESSAGE = preload("res://ui/message/demand_message.tscn")
const ENABLE_ASSETS_MESSAGE = preload("res://ui/message/enable_assets_message.tscn")
const CURTAIL_MESSAGE = preload("res://ui/message/curtail_message.tscn")
const BATTERIES_MESSAGE = preload("res://ui/message/batteries_message.tscn")

@onready var health_manager: HealthManager = %HealthManager
@onready var message_ctnr: VBoxContainer = %MessageCtnr
@onready var disable_messages_button: Button = %DisableMessagesButton
@onready var sun_manager: SunManager = $SunManager
@onready var clock: Clock = $Clock


func _ready() -> void:
	health_manager.health_zeroed.connect(_on_game_over)
	disable_messages_button.pressed.connect(func(): message_ctnr.queue_free())
	call_deferred("_plan_info_messages")


func _process(_delta: float) -> void:
	sun_manager.set_point_of_day(clock.point_of_day)


func _on_game_over() -> void:
	game_over.emit()


func _plan_info_messages() -> void:
	await get_tree().create_timer(3.0).timeout
	_add_message(CONTROLS_MESSAGE)
	await get_tree().create_timer(35.0).timeout
	_add_message(ENABLE_ASSETS_MESSAGE)
	await get_tree().create_timer(10.0).timeout
	_add_message(CURTAIL_MESSAGE)
	await get_tree().create_timer(30.0).timeout
	_add_message(BATTERIES_MESSAGE)
	await get_tree().create_timer(35.0).timeout
	_add_message(DEMAND_MESSAGE)


func _add_message(message_scene: PackedScene) -> void:
	if is_instance_valid(message_ctnr):
		message_ctnr.add_child(message_scene.instantiate())
