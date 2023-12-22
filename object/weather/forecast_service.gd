extends Node3D

var forecasts: Array[Forecast] = []

@export var cloud_spawn_timer: Timer


func _ready() -> void:
	# Generate and store seven random forecasts, probably make the first 7 no clouds
	for i in range(7):
		var forecast := Forecast.new()
		forecast.generate_random_forecast()
		forecasts.append(forecast)
	_output_forecast()


func _predict_next_forecast() -> void:
	var new_forecast := Forecast.new()
	new_forecast.generate_random_forecast()
	forecasts.append(new_forecast)
	_output_forecast()
	_affect_weather(new_forecast)


func _output_forecast() -> void:
	var num_forecasts = min(forecasts.size(), 7)
	for i in range(forecasts.size() - num_forecasts, forecasts.size()):
		var forecast: Forecast = forecasts[i]
		print("Forecast - Cloudiness: ", forecast.get_cloudiness(), " Windiness: ", forecast.get_windiness())
	print("-----------------------------")


func _affect_weather(latest_forecast: Forecast) -> void:
	if latest_forecast.cloudiness_percentage > 0:
		var scaled_percentage: float = 1.0 - latest_forecast.cloudiness_percentage / 100.0
		cloud_spawn_timer.wait_time = lerpf(0.4, 5.0, scaled_percentage)
		cloud_spawn_timer.start()
		print("cloud_spawn_timer.wait_time: ", cloud_spawn_timer.wait_time)
	else:
		cloud_spawn_timer.stop()


func _on_forecast_timer_timeout() -> void:
	_predict_next_forecast()
