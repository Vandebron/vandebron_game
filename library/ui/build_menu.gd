extends ItemList

@export var buildings: Array[BuildingDef] = []:
	set(value):
		buildings = value
		
		clear()
		for building in buildings:
			var index: int = add_item(building.display_name, building.image)
			set_item_metadata(index, building)
			set_item_tooltip(index, str("Build a ", building.display_name))


func _ready() -> void:
	item_clicked.connect(self._on_item_clicked)


func _on_item_clicked(index: int, _pos: Vector2, _mouse_btn: int) -> void:
	var building: BuildingDef = get_item_metadata(index)
	Events.build_initiated.emit(building)
	deselect_all() # TODO: Would feel better if we only did this after building is placed
