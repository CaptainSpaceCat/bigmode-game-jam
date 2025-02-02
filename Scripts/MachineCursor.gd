
class_name MachineCursor
extends Node2D

@export var debug_mode: bool = true  # Toggle this for debug mode
@onready var machineManager: MachineManager = get_node("/root/Main Scene/MachineManager")
@export var inventoryUI: InventoryUI
@export var oreVeinLayer: TileMapLayer
const GRID_SIZE = MachineManager.GRID_SIZE


@onready var placement_sound: SoundPool = $PlacementSound
@onready var delete_sound: SoundPool = $DeleteSound
# which machines we have unlocked
var machine_unlocked: Array[bool] = []
# shapes of all the machines
var machine_shapes: Array[Vector2i] = []
# Prefabs of all the machines
@export var available_machines: Array[PackedScene] = []
# the machine type we have selected currently
var selected_machine_index: int = -1

# start previous belt pos as 1000 blocks away so its basically unreachable until player places belts
var previous_belt_pos: Vector2i = Vector2i.ONE * 1000


func _ready():
	# read machine data from temporary prefab instances
	var i = 0
	for prefab in available_machines:
		var temp_instance: Machine = prefab.instantiate() as Machine
		if temp_instance != null:
			if temp_instance is Machine:
				machine_shapes.append(temp_instance.discrete_shape)
				machine_unlocked.append(temp_instance.unlocked_by_default)
				inventoryUI.set_slot_enabled(i, temp_instance.unlocked_by_default)
			else:
				printerr("Non-machine prefab found in available_machines!")
			temp_instance.queue_free()
		i += 1
	print(machine_shapes)

var previous_mouse_drag_pos: Vector2i = Vector2i.ONE * 10000

func _process(delta):
	# Request a redraw to update cursor visuals
	queue_redraw()
	
	# Reset drag tracking if we release the LMB
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		previous_mouse_drag_pos = Vector2i.ONE * 10000
		
	# Handle left clicking to place machines
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var pos = machineManager.snap_to_grid(get_global_mouse_position())
		if selected_machine_index > -1 and pos != previous_mouse_drag_pos:
			previous_mouse_drag_pos = pos
			var bounds = machine_shapes[selected_machine_index]
			
			# If we're placing conveyer belts, do additional checks
			if selected_machine_index == 0:
				if (previous_belt_pos - pos).length() == 1:
					# Make the previous belt rotate to face this one if needed
					var belt: ConveyerBelt = machineManager.get_machine(previous_belt_pos)
					if belt != null:
						belt.change_output(pos)
				
				# If the machine we're clicking on is itself a conveyer belt,
				# we delete the existing one and let a new one replace it,
				# this time facing the direction of the current mouse drag
				var existing_machine = machineManager.get_machine(pos)
				if existing_machine != null and existing_machine is ConveyerBelt:
					#print("Overwriting belt at: ", existing_machine.discrete_position)
					machineManager.unregister_machine(existing_machine)
					for letter: Letter in existing_machine.get_held_items():
						letter.queue_free()
					existing_machine.queue_free()
			
			# Check to see if the new machine will fit, and if so, place it
			if machineManager.is_area_clear(pos, bounds):
				# Check for ores
				if selected_machine_index == 1: # miner
					var ore_flag = false
					# Check all spots under the miner for ores
					for x in range(bounds.x):
						for y in range(bounds.y):
							var tile_data: TileData = oreVeinLayer.get_cell_tile_data(pos + Vector2i(x, y))
							if tile_data != null:
								ore_flag = true
								break
					if not ore_flag:
						# if none of the spots under the miner are ores, don't allow placement
						return
				var new_machine = place_machine(selected_machine_index, pos)
				# If we just placed a conveyer belt, keep track of where the last placed one is
				if selected_machine_index == 0:
					var belt: ConveyerBelt = new_machine
					if (previous_belt_pos - pos).length() == 1:
						belt.change_input(previous_belt_pos)
						belt.change_output(pos - previous_belt_pos + pos)
					else:
						# Check surrounding tiles to see if any have an output
						# if so, prioritize facing this conveyer's input towards that output
						for offset in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
							var machine = machineManager.get_machine(pos + offset)
							if machine != null and machine.can_provide_output(pos + offset, pos):
								belt.change_input(pos + offset)
								break
					previous_belt_pos = pos
	
	# Handle right clicking to remove machines
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		previous_belt_pos = Vector2i.ONE * 10000
		var pos = machineManager.snap_to_grid(get_global_mouse_position())
		clear_machine(pos)

func place_machine(index: int, pos_index: Vector2i) -> Machine:
	placement_sound.play_sound()
	var prefab = available_machines[index].instantiate()
	prefab.discrete_position = pos_index
	#print("Creating prefab:", prefab.name)
	prefab.scale = Vector2.ONE * 1.2
	create_tween().tween_property(prefab, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_QUAD)
	machineManager.add_child(prefab)
	
	if index == 1: # miner
		for x in range(prefab.discrete_shape.x):
			for y in range(prefab.discrete_shape.y):
				var tile_data: TileData = oreVeinLayer.get_cell_tile_data(pos_index + Vector2i(x,y))
				if tile_data != null:
					prefab.set_word(tile_data.get_custom_data("word"))
					break
	
	# assume center of prefab is in the center of a grid position
	prefab.position = Vector2(pos_index) * GRID_SIZE + Vector2.ONE * GRID_SIZE/2 # thus we add half a tile
	# Register the machine to the machine_map
	machineManager.register_machine(pos_index, prefab)
	# return a reference to this machine in case it's needed
	return prefab


func clear_machine(pos: Vector2i):
	var machine = machineManager.get_machine(pos)
	if machine != null and machine.is_destructible:
		delete_sound.play_sound()
		for item: Letter in machine.get_held_items():
			item.queue_free()
		machineManager.unregister_machine(machine)
		machine.queue_free()

func unlock_machine(index: int):
	machine_unlocked[index] = true
	inventoryUI.set_slot_enabled(index, true)

# Handle input
func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				selected_machine_index = -1
				inventoryUI.set_selected_slot(-1)
				print("Cleared machine selection")
			elif event.keycode >= KEY_1 and event.keycode <= KEY_9:
				var new_index = event.keycode - KEY_1
				if new_index < available_machines.size() and selected_machine_index != new_index and machine_unlocked[new_index]:
					selected_machine_index = new_index
					inventoryUI.set_selected_slot(selected_machine_index)
					print("Selected machine: " + str(selected_machine_index))
			else:
				# all keys uncaught above get sent to the machine we're hovering over, if any
				var pos = machineManager.snap_to_grid(get_global_mouse_position())
				var m = machineManager.get_machine(pos)
				if m != null:
					m.handle_key_press(event.keycode)
	
	elif event is InputEventMouseButton:
		var pos = machineManager.snap_to_grid(get_global_mouse_position())
		var m = machineManager.get_machine(pos)
		if m != null:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
				m.handle_key_press(KEY_UP)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
				m.handle_key_press(KEY_DOWN)


# Debug draw mode, might be used in the actual game tbh
func _draw():
	var camera = get_viewport().get_camera_2d()  # Get the active Camera2D
	if camera == null:
		return  # No camera found, avoid errors

	var screen_size = get_viewport_rect().size
	var zoom_factor = camera.zoom.x  # Assumes uniform zoom in x and y
	var cam_pos = camera.global_position

	# Calculate the top-left corner of the screen in world coordinates
	var top_left = cam_pos - (screen_size / 2) * zoom_factor
	var bottom_right = cam_pos + (screen_size / 2) * zoom_factor

	# Snap starting positions to the grid
	var start_x = floor(top_left.x / GRID_SIZE) * GRID_SIZE
	var start_y = floor(top_left.y / GRID_SIZE) * GRID_SIZE
	var end_x = ceil(bottom_right.x / GRID_SIZE) * GRID_SIZE
	var end_y = ceil(bottom_right.y / GRID_SIZE) * GRID_SIZE

	if debug_mode:
		# Draw Vertical Grid Lines
		for x in range(start_x, end_x, GRID_SIZE):
			draw_line(Vector2(x, top_left.y), Vector2(x, bottom_right.y), Color(1, 1, 1, 0.2))

		# Draw Horizontal Grid Lines
		for y in range(start_y, end_y, GRID_SIZE):
			draw_line(Vector2(top_left.x, y), Vector2(bottom_right.x, y), Color(1, 1, 1, 0.2))

	if selected_machine_index > -1:
		# Get mouse position in world space
		var mouse_pos = get_global_mouse_position()
		var bounds = machine_shapes[selected_machine_index]
		var grid_pos = machineManager.snap_to_grid(mouse_pos)
		
		for x in range(bounds.x):
			for y in range(bounds.y):
				var chosen_color = Color(1, 0, 0.4, 0.5) # red (assume blocked by default)
				var m = machineManager.get_machine(grid_pos + Vector2i(x, y))
				if m == null or (selected_machine_index == 0 and m is ConveyerBelt):
					chosen_color = Color(0.2, 0.5, 1, 0.5) # blue (open slot)
				if m == null and selected_machine_index == 1:
					var tile_data: TileData = oreVeinLayer.get_cell_tile_data(grid_pos + Vector2i(x, y))
					if tile_data == null:
						chosen_color = Color(1, 0, 0.4, 0.5) # back to red
				# Snap mouse position to grid
				var snapped_pos = (Vector2(grid_pos) + Vector2(x, y)) * GRID_SIZE# + Vector2.ONE * GRID_SIZE/2
				# Draw a red dot at the center of the snapped grid cell
				draw_rect(Rect2(snapped_pos + Vector2.ONE*.5, Vector2.ONE * (GRID_SIZE - 1)), chosen_color, false, 2.0)
