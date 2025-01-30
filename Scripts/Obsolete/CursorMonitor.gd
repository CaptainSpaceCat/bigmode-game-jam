extends Node2D

@export var debug_mode: bool = true  # Toggle this for debug mode
const GRID_SIZE = 16

func _ready():
	pass

func _process(delta):
	if debug_mode:
		queue_redraw()  # Request a redraw to update debug visuals
	
	var mouse_pos = get_global_mouse_position()
	var snapped_pos = Vector2(
		floor(mouse_pos.x / GRID_SIZE) * GRID_SIZE,
		floor(mouse_pos.y / GRID_SIZE) * GRID_SIZE
	)


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

		# Get mouse position in world space
		var mouse_pos = get_global_mouse_position()

		# Snap mouse position to grid
		var snapped_pos = Vector2(
			floor(mouse_pos.x / GRID_SIZE) * GRID_SIZE + GRID_SIZE / 2,
			floor(mouse_pos.y / GRID_SIZE) * GRID_SIZE + GRID_SIZE / 2
		)

		# Draw a red dot at the center of the snapped grid cell
		draw_circle(snapped_pos, 5, Color(1, 0, 0.4, 0.5))

