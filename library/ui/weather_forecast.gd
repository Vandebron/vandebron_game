extends ItemList

@export var sunny_icon: CompressedTexture2D
@export var night_icon: CompressedTexture2D
@export var cloudy_icon: CompressedTexture2D
@export var light_cloud_icon: CompressedTexture2D
@export var windy_icon: CompressedTexture2D
@onready var weather_icons: Array[CompressedTexture2D]

@export var current_weather_forecast: Array[CompressedTexture2D]
# Called when the node enters the scene tree for the first time.
func _ready():
	clear()
	weather_icons = [sunny_icon, night_icon, cloudy_icon, light_cloud_icon, windy_icon]
	for i in range(0, 7):
		var icon = weather_icons.pick_random()
		current_weather_forecast.append(icon)
		add_item("", icon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_forecast():
	current_weather_forecast.pop_front()
	current_weather_forecast.push_back(weather_icons.pick_random())
	clear()
	for icon in current_weather_forecast:
		add_item("", icon)
	

func _on_timer_timeout():
	update_forecast()
