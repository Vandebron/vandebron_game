class_name WeatherForecastList extends ItemList

const AMOUNT_TO_SHOW: int = 3

@export var sunny_icon: CompressedTexture2D
@export var night_icon: CompressedTexture2D
@export var cloudy_icon: CompressedTexture2D #In use
@export var light_cloud_icon: CompressedTexture2D 
@export var windy_icon: CompressedTexture2D #In use
@export var cloudy_windy_icon: CompressedTexture2D #In use
@onready var weather_icons: Array[CompressedTexture2D]

@export var current_weather_forecast: Array[CompressedTexture2D]

#TODO: Retrieve from the ForecastTimer
@export var forcast_cycle_ms: int = 5_000


func _ready() -> void:
	clear()
	weather_icons = [sunny_icon, night_icon, cloudy_icon, light_cloud_icon, windy_icon, cloudy_windy_icon]
	for i in range(0, AMOUNT_TO_SHOW):
		current_weather_forecast.append(cloudy_windy_icon)
		add_item("", cloudy_windy_icon, false)


func update_forecast(new_forecast: Forecast, clock: Clock) -> void:
	determine_next_forecast(new_forecast, clock)
	clear()
	for icon in current_weather_forecast:
		add_item("", icon, false)


func determine_next_forecast(new_forecast: Forecast, clock: Clock) -> void:
	current_weather_forecast.pop_front()
	if (new_forecast.cloud_coverage >= 0.5 && new_forecast.wind_speed >= 0.5):
		current_weather_forecast.push_back(cloudy_windy_icon)
	elif (new_forecast.cloud_coverage >= 0.5):
		current_weather_forecast.push_back(cloudy_icon)
	elif (new_forecast.wind_speed >= 0.5):
		current_weather_forecast.push_back(windy_icon)
	else:
		#TODO: Might be off by 1 increment
		var time_of_last_forecast = clock.get_part_of_day_plus(forcast_cycle_ms * 7)
		if (time_of_last_forecast < 6):
			current_weather_forecast.push_back(night_icon)
		else:
			current_weather_forecast.push_back(sunny_icon)
