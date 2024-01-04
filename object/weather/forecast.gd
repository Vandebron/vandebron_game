class_name Forecast extends Node3D

var cloud_coverage: float
var wind_speed: float

enum WindSpeed { LOW, MEDIUM, HIGH }
enum CloudCoverage { LOW, MEDIUM, HIGH }

# Function to generate random forecast values
static func generate_random_forecast() -> Forecast:
	var forecast: Forecast = Forecast.new()
	
	match randi_range(0, WindSpeed.size()) as WindSpeed:
		WindSpeed.LOW: forecast.wind_speed = 0
		WindSpeed.MEDIUM: forecast.wind_speed = 0.5
		WindSpeed.HIGH: forecast.wind_speed = 1
		
	match randi_range(0, CloudCoverage.size()) as CloudCoverage:
		CloudCoverage.LOW: forecast.cloud_coverage = 0
		CloudCoverage.MEDIUM: forecast.cloud_coverage = 0.5
		CloudCoverage.HIGH: forecast.cloud_coverage = 1
	return forecast
	
# Function to generate random forecast values
func initial_forecast() -> void:
	cloud_coverage = 0.5
	wind_speed = 0.5

	
