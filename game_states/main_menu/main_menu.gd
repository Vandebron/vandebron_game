extends Node3D
class_name MainMenu

signal game_started

@onready var start_game_btn: Button = %StartGameBtn
@onready var settings_btn: MenuButton = %SettingsBtn
@onready var quit_game_btn: Button = %QuitBtn


func _ready() -> void:
	start_game_btn.pressed.connect(_on_game_started)
	#settings_btn.pressed.connect(_open_settings_popup)
	quit_game_btn.pressed.connect(_quit)


func _on_game_started() -> void:
	game_started.emit()

func _open_settings_popup() -> void:
	print("JFKLDJSKL")


func _quit() -> void:
	# ideally we need to create a different check for mobile games, 
	# or not even display the exit button at all
	# (android -> NOTIFICATION_WM_GO_BACK_REQUEST)
	# nothing for iOS
	# later add a popup that confirms the closing with Yes/No
	print_debug("Sending out close request")
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

# not sure where to put this...
# https://docs.godotengine.org/en/stable/tutorials/inputs/handling_quit_requests.html#sending-your-own-quit-notification
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit() # default behavior
