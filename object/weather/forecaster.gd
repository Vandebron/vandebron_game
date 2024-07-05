class_name Forecaster extends Node3D

var forecasts: Array[Forecast] = []

@onready var cloud_spawn_timer: Timer = $SpawnCloud
@onready var forecast_timer: Timer = $ForecastTimer
@export var clock: Clock
@export var forecast_list_comp: WeatherForecastList

func _init() -> void:
	# Generate and store seven random forecasts, probably make the first 7 no clouds
	for i in range(7):
		var forecast := Forecast.new()
		forecast.initial_forecast()
		forecasts.append(forecast)


func _ready() -> void:
	forecast_timer.timeout.connect(_predict_next_forecast)
	

func _predict_next_forecast() -> void:
	var new_forecast: Forecast = Forecast.generate_random_forecast()
	
	forecasts.pop_front()
	forecasts.push_back(new_forecast)
	
	_output_forecast()
	
	forecast_list_comp.update_forecast(new_forecast, clock)
	_affect_cloud_spawn_rate(new_forecast)


func _output_forecast() -> void:
	var num_forecasts = min(forecasts.size(), 7)
	for i in range(forecasts.size() - num_forecasts, forecasts.size()):
		var forecast: Forecast = forecasts[i]
		print_verbose("Forecast - Cloudiness: ", forecast.cloud_coverage, " Windiness: ", forecast.wind_speed)
	print_verbose("-----------------------------")


func _affect_cloud_spawn_rate(latest_forecast: Forecast) -> void:
	if latest_forecast.cloud_coverage > 0:
		cloud_spawn_timer.wait_time = lerpf(0.1, 5.0, 1 - latest_forecast.cloud_coverage)
		cloud_spawn_timer.start()
		print_verbose("cloud_spawn_timer.wait_time: ", cloud_spawn_timer.wait_time)
	else:
		cloud_spawn_timer.stop()

	
func get_current_forecast() -> Forecast:
	return forecasts[0]
