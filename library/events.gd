extends Node

signal build_initiated(building: BuildingDef)
signal build_cancelled()
signal build_confirmed()

signal night_started()
signal night_ended()
signal season_started(season: Weather.Season)
signal season_ended(season: Weather.Season)
