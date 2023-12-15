extends Node3D

#From ChatGpt
#Calm:
#Wind Speed: 0 - 5 km/h
#Light Air:
#Wind Speed: 6 - 19 km/h#Description: Wind can be felt on the face; leaves rustle but do not move significantly.
#Light Breeze:
#Wind Speed: 20 - 39 km/h
#Gentle Breeze:
#Wind Speed: 40 - 59 km/h
#Moderate Breeze:
#Wind Speed: 60 - 79 km/h
#Fresh Breeze:
#Wind Speed: 80 - 99 km/h
#Strong Breeze:
#Wind Speed: 100 - 119 km/h
#Near Gale:
#Wind Speed: 120 - 139 km/h
#Gale:
#Wind Speed: 140 - 159 km/h
#Severe Gale:
#Wind Speed: 160 - 179 km/h
#Storm:
#Wind Speed: 180 - 199 km/h
#Violent Storm:
#Wind Speed: 200 - 249 km/h
#Hurricane / Typhoon:
#Wind Speed: 250 km/h and above

class_name Forecast

var cloudinessPercentage : int = 0 # Range from (0% to 100%)
var windinesskmH : float = 0.0 # Range from 0.0 to 1.0 (0% to 100%)

# Constants
const CLOUDINESS_MAX = 100
const WINDINESS_MAX = 250

# Methods
func _ready():
	# Ensure values are within valid range
	cloudinessPercentage = clamp(cloudinessPercentage, 0, CLOUDINESS_MAX)
	windinesskmH = clamp(windinesskmH, 0.0, WINDINESS_MAX)

# Setter methods for cloudiness and windiness with range validation
func set_cloudiness(value: float) -> void:
	cloudinessPercentage = clamp(value, 0.0, CLOUDINESS_MAX)

func set_windiness(value: float) -> void:
	windinesskmH = clamp(value, 0.0, WINDINESS_MAX)

func get_cloudiness() -> float:
	return cloudinessPercentage

func get_windiness() -> float:
	return windinesskmH
	
# Function to generate random forecast values
func generate_random_forecast() -> void:
	cloudinessPercentage = randf_range(0.0, CLOUDINESS_MAX)
	windinesskmH = randf_range(0.0, WINDINESS_MAX)
