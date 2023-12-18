extends Node3D

var forecasts : Array = []

func _ready():
	# Generate and store seven random forecasts, probably make the first 7 no clouds
	for i in range(7):
		var forecast = Forecast.new()
		forecast.generate_random_forecast()
		forecasts.append(forecast)
	_output_forecast()

func _predictNextForecast():
	var new_forecast = Forecast.new()
	new_forecast.generate_random_forecast()
	forecasts.append(new_forecast)
	_output_forecast()
	
func _output_forecast():
	var num_forecasts = min(forecasts.size(), 7)
	for i in range(forecasts.size() - num_forecasts, forecasts.size()):
		var forecast = forecasts[i]
		print("Forecast - Cloudiness: ", forecast.get_cloudiness(), " Windiness: ", forecast.get_windiness())
	print("-----------------------------")
	

func _on_forecast_timer_timeout():
	_predictNextForecast()
