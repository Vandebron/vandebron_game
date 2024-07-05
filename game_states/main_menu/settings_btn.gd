extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	#self._settings = preload("res://ui/settings_menu.tscn").instantiate()
	self.pressed.connect(self._on_button_press)

func _on_button_press():
	pass
	#get_tree().current_scene.add_child(self._settings)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
