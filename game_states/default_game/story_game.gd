extends Game

const WELCOME_MESSAGE = preload("res://ui/message/StoryMessages/welcome_message.tscn")
const FAILURE_MESSAGE = preload("res://ui/message/StoryMessages/failure_message.tscn")


@onready var health_manager: HealthManager = %HealthManager
@onready var message_ctnr: VBoxContainer = %MessageCtnr
@onready var disable_messages_button: Button = %DisableMessagesButton
@onready var sun_manager: SunManager = $SunManager
@onready var clock: Clock = $Clock
@onready var coal_plant: Node3D = $EnergyGrid/CoalPlant
@onready var win_timer: Timer = %WinTimer

@onready var dialogue: Control = %Dialogue
@onready var ui: Control = %UI

enum STORY_SITUATION {
	INTRODUCTION,
	FAILURE
}

var failed_attempt: bool = false

func _ready() -> void:
	health_manager.health_zeroed.connect(_on_game_over)
	coal_plant.coal_turned_off.connect(_coal_change_off)
	coal_plant.coal_turned_on.connect(_coal_change_on)
	win_timer.timeout.connect(_on_game_over)
	disable_messages_button.pressed.connect(func(): message_ctnr.queue_free())
	call_deferred("_plan_info_messages")


func _process(_delta: float) -> void:
	sun_manager.set_point_of_day(clock.point_of_day)

func _on_game_over() -> void:
	game_over.emit()

func _coal_change_on() -> void:
	
	
	print("failed_attempt " + str(failed_attempt))
	if (failed_attempt):
		failed_attempt = false
		win_timer.stop()
		ui.visible = false
		dialogue.change_to_failure()
		dialogue.visible = true
		dialogue.current_item_index = 0
		dialogue.show_text(STORY_SITUATION.FAILURE)
	
func _coal_change_off() -> void:
	print()
	failed_attempt = true
	win_timer.start()
	

func _plan_info_messages() -> void:
	await get_tree().create_timer(0.5).timeout
	_add_message(WELCOME_MESSAGE)


func _add_message(message_scene: PackedScene) -> void:
	if is_instance_valid(message_ctnr):
		message_ctnr.add_child(message_scene.instantiate())
