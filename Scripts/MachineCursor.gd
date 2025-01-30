extends Node2D

@export var debug_mode: bool = true  # Toggle this for debug mode
@export var machineManager: MachineManager
const GRID_SIZE = 16

# which machines we have unlocked
var machine_locks: Array[bool] = []
# shapes of all the machines
var machine_shapes: Array[Vector2i] = []
# Prefabs of all the machines
@export var available_machines: Array[PackedScene] = []
# the machine type we have selected currently
var selected_machine_index: int = -1


func _ready():
	# read machine data from temporary prefab instances
	for prefab in available_machines:
		var temp_instance: Machine = prefab.instantiate() as Machine
		if temp_instance != null:
			if temp_instance is Machine:
				machine_shapes.append(temp_instance.discrete_shape)
				machine_locks.append(temp_instance.locked_by_default)
			else:
				printerr("Non-machine prefab found in available_machines!")
			temp_instance.queue_free()
	print(machine_shapes)

func _process(delta):
	# Request a redraw to update debug visuals
	if debug_mode:
		queue_redraw()
	
	# Handle left clicking to place machines
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if selected_machine_index > -1:
			var pos = snap_to_grid(get_global_mouse_position())
			var bounds = machine_shapes[selected_machine_index]
			if machineManager.is_area_clear(pos, bounds):
				place_machine(selected_machine_index, pos)
	
	# Handle right clicking to remove machines
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var pos = snap_to_grid(get_global_mouse_position())
		var machine = machineManager.get_machine(pos)
		if machine != null:
			machineManager.unregister_machine(machine)
			machine.queue_free()


func place_machine(index: int, pos_index: Vector2i):
	var prefab = available_machines[index].instantiate()
	prefab.discrete_position = pos_index
	print("Creating prefab:", prefab.name)
	add_child(prefab)
	
	# assume center of prefab is in the center of a grid position
	prefab.position = Vector2(pos_index) * GRID_SIZE + Vector2.ONE * GRID_SIZE/2 # thus we add half a tile
	
	machineManager.register_machine(pos_index, prefab)


func clear_machine(pos: Vector2i):
	var machine = machineManager.get_machine(pos)
	if machine != null:
		machineManager.unregister_machine(machine)

# Snap a global position to the nearest grid index
func snap_to_grid(pos: Vector2) -> Vector2i:
	return Vector2i(
		floor(pos.x / GRID_SIZE),
		floor(pos.y / GRID_SIZE)
	)


# Handle input
func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			selected_machine_index = -1
			print("Cleared machine selection")
		elif event.pressed and event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var new_index = event.keycode - KEY_1
			if new_index < available_machines.size() and selected_machine_index != new_index:
				selected_machine_index = new_index
				print("Selected machine: " + str(selected_machine_index))


# Debug draw mode, might be used in the actual game tbh
func _draw():
	if debug_mode:
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
			
			for x in range(bounds.x):
				for y in range(bounds.y):
					# Snap mouse position to grid
					var snapped_pos = Vector2(snap_to_grid(mouse_pos)) * GRID_SIZE + Vector2.ONE * GRID_SIZE/2
					# Draw a red dot at the center of the snapped grid cell
					draw_circle(snapped_pos + Vector2(x, y) * GRID_SIZE, 5, Color(1, 0, 0.4, 0.5))

