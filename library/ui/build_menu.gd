extends ItemList
class_name BuildMenu

@export var buildings: Array[BuildingDef] = []:
	set(value):
		buildings = value
		
		clear()
		for building in buildings:
			var index: int = add_item(building.display_name, building.image)
			set_item_metadata(index, building)
			set_item_tooltip(index, str("Build a ", building.display_name))
		
		select_current_item()


func _init() -> void:
	item_selected.connect(self._on_item_selected)


func _input(event: InputEvent) -> void:
	if event.is_action_released("build_initiate"):
		select_current_item()
	elif event.is_action_released("cycle_build_list_left"):
		cycle_left()
	elif event.is_action_released("cycle_build_list_right"):
		cycle_right()


func cycle_left() -> void:
	var new_index: int = wrapi(_get_current_index() - 1, 0, item_count)
	_select_and_trigger(new_index)


func cycle_right() -> void:
	var new_index: int = wrapi(_get_current_index() + 1, 0, item_count)
	_select_and_trigger(new_index)


func select_current_item() -> void:
	var index: int = _get_current_index()
	_select_and_trigger(index)


func _select_and_trigger(index: int) -> void:
	select(index)
	item_selected.emit(index)


func _get_current_index() -> int:
	return get_selected_items()[0] if is_anything_selected() else 0


func _on_item_selected(index: int) -> void:
	var building: BuildingDef = get_item_metadata(index)
	Events.build_initiated.emit(building)
