class_name BuildMenu extends Control

signal build_initiated(building_def: BuildingDef)

const DRAWER_BOX_BUTTON_SCN: PackedScene = preload("res://ui/drawer_box/drawer_box_button.tscn")

@export var buildings: Array[BuildingDef] = []: set=_set_buildings


func clear() -> void:
	for child in $List.get_children():
		child.queue_free()


func _set_buildings(value: Array[BuildingDef]) -> void:
	buildings = value
	
	clear()
	for building_def: BuildingDef in buildings:
		var button: DrawerBoxButton = DRAWER_BOX_BUTTON_SCN.instantiate()
		button.set_icon(building_def.image)
		$List.add_child(button)
		button.pressed.connect(self.build_initiated.emit.bind(building_def))
	$List.columns = buildings.size()
