extends TextureRect

@export var index: int = 0

func _process(delta):
	return
	print(get_global_rect(), get_global_mouse_position())

func _gui_input(event):
	#print(event)
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			GlobalSignals.select_inventory_slot.emit(index)
