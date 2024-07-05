extends Control

var expressions := {
	"happy": preload("res://ui/art/emotion_happy.png"),
	"regular": preload("res://ui/art/emotion_regular.png"),
	"sad": preload("res://ui/art/emotion_sad.png"),
}

var dialogue_items: Array[Dictionary] = [
	{
		"expression": expressions["happy"],
		"text": "Welcome!!!",
		"event": 0
	},
	{
		"expression": expressions["sad"],
		"text": "The world is dying...",
		"event": 1
	},
	{
		"expression": expressions["regular"],
		"text": "But I believe in UUU!",
		"event": 0
	},
	{
		"expression": expressions["happy"],
		"text": "Lets save the world!!!",
		"event": 2
	},
	{
		"expression": expressions["regular"],
		"text": "Select here to choose an new asset to place",
		"event": 3
	},
	{
		"expression": expressions["regular"],
		"text": "Select here to be able to turn off an asset",
		"event": 4
	},
		{
		"expression": expressions["regular"],
		"text": "We do this when there is too much energy on the grid",
		"event": 5
	},
	{
		"expression": expressions["regular"],
		"text": "Too help stabilize it",
		"event": 0
	},
	{
		"expression": expressions["happy"],
		"text": "Let's begin!",
		"event": 0
	}
]

var failure_items: Array[Dictionary] = [
	{
		"expression": expressions["sad"],
		"text": "Woah there!!!",
		"event": 0
	},
		{
		"expression": expressions["regular"],
		"text": "Looks like you were not ready to shut it down",
		"event": 0
	},
	{
		"expression": expressions["happy"],
		"text": "Try placing some more solar and wind assets, and...",
		"event": 0
	},
	{
		"expression": expressions["happy"],
		"text": "GIT GUD!",
		"event": 0
	}
]

var current_item_index := 0
var story_mode := false

enum STORY_SITUATION {
	INTRODUCTION,
	FAILURE
}

var current_story_situation := STORY_SITUATION.INTRODUCTION

@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var next_button: Button = %NextButton
@onready var body: TextureRect = %Body
@onready var expression: TextureRect = %Expression

#Hacky importing
@onready var water: MeshInstance3D = %Water
@onready var ui: Control = %UI

@onready var manage_arrow: TextureRect = %ManageArrow
@onready var building_arrow: TextureRect = %BuildingArrow


func _ready() -> void:
	show_text(STORY_SITUATION.INTRODUCTION)
	next_button.pressed.connect(advance)


func change_to_failure() -> void:
	current_story_situation = STORY_SITUATION.FAILURE

func show_text(situation: STORY_SITUATION) -> void:
	
	match situation:
		STORY_SITUATION.INTRODUCTION:
			var current_item := dialogue_items[current_item_index]
			rich_text_label.text = current_item["text"]
			expression.texture = current_item["expression"]
	
			if (current_item["event"] == 1):
				var tween := create_tween()
				tween.tween_property(water, "position:y", 2.0, 3)
			if (current_item["event"] == 2):
				var tween := create_tween()
				tween.tween_property(water, "position:y", -0.2, 1)
			if (current_item["event"] == 3):
				building_arrow.visible = true
			if (current_item["event"] == 4):
				building_arrow.visible = false
				manage_arrow.visible = true
			if (current_item["event"] == 5):
				building_arrow.visible = false
				manage_arrow.visible = false
		STORY_SITUATION.FAILURE:
			var current_item := failure_items[current_item_index]
			rich_text_label.text = current_item["text"]
			expression.texture = current_item["expression"]
			
	rich_text_label.visible_ratio = 0.0
	var tween := create_tween()
	var text_appearing_duration := 1.0
	tween.tween_property(rich_text_label, "visible_ratio", 1.0, text_appearing_duration)

	slide_in()

func advance() -> void:
	current_item_index += 1
	var dia_size = 0
	
	if (current_story_situation == STORY_SITUATION.INTRODUCTION):
		dia_size = dialogue_items.size()
	else:
		dia_size = failure_items.size()
	
	
	if current_item_index == dia_size:
		var tween := create_tween()
		tween.tween_property(water, "position:y", -0.2, 1)
		ui.visible = true
		manage_arrow.visible = false
		building_arrow.visible = false
		self.visible = false
	else:
		show_text(current_story_situation)

func slide_in() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_OUT)
	body.position.x = 200.0
	tween.tween_property(body, "position:x", 0.0, 0.3)
	body.modulate.a = 0.0
	tween.parallel().tween_property(body, "modulate:a", 1.0, 0.2)
