extends Node3D
class_name Forecast

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

var cloudiness: int: set=_set_cloudiness_percentage, get=_get_cloudiness_percentage
var windiness: float: set=_set_windiness_kmh, get=_get_windiness_kmh

var _cloudiness_percentage: int = 0 # Range from (0% to 100%)
var _windiness_kmh: float = 0.0 # Range from 0.0 to 1.0 (0% to 100%)

# Constants
const CLOUDINESS_MAX: int = 100
const WINDINESS_MAX: int = 250

# Methods
func _ready() -> void:
	# Ensure values are within valid range
	cloudiness = clampi(cloudiness, 0, CLOUDINESS_MAX)
	windiness = clampf(windiness, 0.0, WINDINESS_MAX)


# Setter methods for cloudiness and windiness with range validation
func _set_cloudiness_percentage(value: int) -> void:
	_cloudiness_percentage = clampi(value, 0, CLOUDINESS_MAX)


func _get_cloudiness_percentage() -> int:
	return _cloudiness_percentage


func _set_windiness_kmh(value: float) -> void:
	_windiness_kmh = clampf(value, 0.0, WINDINESS_MAX)


func _get_windiness_kmh() -> float:
	return _windiness_kmh


# Function to generate random forecast values
func generate_random_forecast() -> void:
	cloudiness = randi_range(0, CLOUDINESS_MAX)
	windiness = randf_range(0.0, WINDINESS_MAX)
