extends Node

signal build_initiated(building: BuildingDef)
signal build_cancelled()
signal build_confirmed()

signal part_of_day_started(part: Weather.DayPart)
signal part_of_day_ended(part: Weather.DayPart)
signal season_started(season: Weather.Season)
signal season_ended(season: Weather.Season)
