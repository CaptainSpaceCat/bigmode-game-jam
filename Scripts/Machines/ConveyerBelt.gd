class_name ConveyerBelt
extends Machine

@export var item_render_positions: Array[Node2D]

var renderA: Node2D
var renderB: Node2D

var slotA: Letter
var slotB: Letter

func _init() -> void:
	self.add_input(Vector2i(-1,0), Vector2i.ZERO)
	self.add_output(Vector2i.ZERO, Vector2i(1,0))

func _ready() -> void:
	renderA = item_render_positions[3]
	renderB = item_render_positions[1]

func change_output(out_world_pos: Vector2i):
	var out_pos = self.grid_to_local(out_world_pos)
	self.clear_outputs()
	self.add_output(Vector2i.ZERO, out_pos)
	
	if self.get_input(0).from == out_world_pos:
		# We just set the output to the same side as the input
		# Assume we set the output for a reason, so move the input
		self.change_input(discrete_position - out_pos)
	
	var dir = self.get_relative_direction(Vector2i.ZERO, out_pos)
	if dir >= 0:
		renderB = item_render_positions[dir]
		if debug_enabled:
			queue_redraw()

func change_input(in_world_pos: Vector2i):
	var in_pos = self.grid_to_local(in_world_pos)
	self.clear_inputs()
	self.add_input(in_pos, Vector2i.ZERO)
	
	
	if self.get_output(0).to == in_world_pos:
		# We just set the input to the same side as the output
		# Assume we set the input for a reason, so move the output
		self.change_output(discrete_position - in_pos)
	
	var dir = self.get_relative_direction(Vector2i.ZERO, in_pos)
	if dir >= 0:
		renderA = item_render_positions[dir]
		if debug_enabled:
			queue_redraw()

func send_letter_to_channel(channel: int, letter: Letter) -> bool:
	if channel == 0:
		if slotA == null:
			slotA = letter
			letter.send_to(renderA.global_position)
			return true
	return false


func perform_cycle(machine_map: Dictionary) -> void:
	# try to move item from slot B into the next tile
	if slotB != null:
		var io: MachineIO = get_output(0)
		var other_machine: Machine = machine_map.get(io.to)
		if other_machine and other_machine.can_accept_input(io.from, io.to):
			if other_machine.try_accept_input(io.from, io.to, slotB):
				slotB = null
					
	# try to move item in slot A to slot B
	if slotA != null:
		if slotB == null:
			slotA.send_to(renderB.global_position)
			slotB = slotA
			slotA = null


func get_held_items() -> Array:
	var items = []
	if slotA != null:
		items.append(slotA)
	if slotB != null:
		items.append(slotB)
	return items

@export var spriteStraight: AnimatedSprite2D
@export var spriteBent: AnimatedSprite2D

func _draw():
	if debug_enabled:
		draw_circle(renderA.position, 3, Color(0.1, 1, 0.2, 0.2))
		draw_circle(renderB.position, 3, Color(1, 0.2, 0, 0.2))
	
	# Set the texture and orientation based on outputs
	var in_dir = self.get_relative_direction(Vector2i.ZERO, self.input_array[0].from)
	var out_dir = self.get_relative_direction(Vector2i.ZERO, self.output_array[0].to)
	
	var diff = abs(in_dir - out_dir)
	if diff == 2: # conveyer is straight
		spriteStraight.rotation = PI/2 * in_dir
		spriteStraight.visible = true
		spriteBent.visible = false
	elif diff == 1 or diff == 3: # conveyer is bent
		spriteBent.rotation = PI/2 * in_dir
		spriteStraight.visible = false
		spriteBent.visible = true
		
		# Just trust me, it works
		spriteBent.flip_h = (in_dir + 3) % 4 == out_dir
	else:
		printerr("Conveyer fold error")
	
