class_name Forecaster extends Node3D

const CLOUD_MATERIAL = preload("res://object/weather/cloud_material.tres")

var forecasts: Array[Forecast] = []

@export var clock: Clock
@export var forecast_list_comp: WeatherForecastList

@onready var forecast_timer: Timer = $ForecastTimer
@onready var cloud_particles: GPUParticles3D = $CloudParticles

func _init() -> void:
	# Generate and store seven random forecasts, probably make the first 7 no clouds
	for i in range(7):
		var forecast := Forecast.new()
		forecast.initial_forecast()
		forecasts.append(forecast)


func _ready() -> void:
	forecast_timer.timeout.connect(_predict_next_forecast)
	cloud_particles.amount_ratio = 0.25
	
	cloud_particles.draw_pass_1.surface_set_material(0, CLOUD_MATERIAL)
	

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
	cloud_particles.amount_ratio = latest_forecast.cloud_coverage

	
func get_current_forecast() -> Forecast:
	return forecasts[0]
