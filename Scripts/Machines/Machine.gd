class_name Machine
extends Node2D

var update_flag := false
var discrete_position: Vector2i  # World grid position of the machine
var discrete_shape := Vector2i.ONE # Width and height of the machine
var unlocked_by_default := true
var is_destructible := true

# accepts a vector2i position on the world grid
# returns the same vector relative to this machine's origin
func grid_to_local(pos: Vector2i) -> Vector2i:
	return pos - discrete_position

# Check whether the inserted IO will be accepted by this machine
func can_accept_input(from: Vector2i, to: Vector2i) -> bool:
	for io in input_array:
		# our saved IOs are relative to the center of this machine
		# we need to add discrete_position to be able to compare to another machine's IO
		if io.from + discrete_position == from and io.to + discrete_position == to:
			return true
	return false

func can_provide_output(from: Vector2i, to: Vector2i) -> bool:
	for io in output_array:
		# our saved IOs are relative to the center of this machine
		# we need to add discrete_position to be able to compare to another machine's IO
		if io.from + discrete_position == from and io.to + discrete_position == to:
			return true
	return false

# Function for passing letters into a machine
# returns true if the machine successfully accepts a letter from the specified source
func try_accept_input(from: Vector2i, to: Vector2i, letter: Letter) -> bool:
	for i in range(len(input_array)):
		var io = input_array[i]
		# our saved IOs are relative to the center of this machine
		# we need to add discrete_position to be able to compare to another machine's IO
		if io.from + discrete_position == from and io.to + discrete_position == to:
			return send_letter_to_channel(i, letter)
	return false


func try_send_to_output(machine_map: Dictionary, letter: Letter, index: int = 0) -> bool:
	var io: MachineIO = self.get_output(index)
	var other_machine: Machine = machine_map.get(io.to)
	if other_machine and other_machine.can_accept_input(io.from, io.to):
		return other_machine.try_accept_input(io.from, io.to, letter)
	return false


# This should get overridden in derived classes to customize input channels
func send_letter_to_channel(channel: int, letter: Letter) -> bool:
	return false


func handle_key_press(key: int):
	pass

# This should get overridden in derived classes to customize the machine's cycle
func perform_cycle(machine_map: Dictionary) -> void:
	pass

func process_output_buffer(machine_map: Dictionary, index: int, buffer: LetterBuffer):
	if buffer.is_full:
		buffer.dequeue_to_hand()
	
	# If our output buffer is now holding a letter ...
	if buffer.held_letter != null:
		var io: MachineIO = self.get_output(index)
		# ... and there's a machine at the output...
		var other_machine: Machine = machine_map.get(io.to)
		# ... and that machine has a corresponding input...
		if other_machine and other_machine.can_accept_input(io.from, io.to):
			# ... and the other machine accepts the letter ...
			if other_machine.try_accept_input(io.from, io.to, buffer.held_letter):
				# ... the letter has been taken in by the other machine,
				# we can delete our buffer's reference
				buffer.clear_held_letter()

func get_held_items() -> Array:
	return []

func _exit_tree():
	for item in get_held_items():
		item.queue_free()


func shrink_and_free(duration: float = 0.2):
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, duration)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.connect("finished", Callable(self, "queue_free"))

# Store and retrieve IO objects

var input_array: Array = []
var output_array: Array = []
var input_array_global: Array = []
var output_array_global: Array = []

func add_input(from: Vector2i, to: Vector2i) -> void:
	input_array.append(MachineIO.new(from, to))

func add_output(from: Vector2i, to: Vector2i) -> void:
	output_array.append(MachineIO.new(from, to))

func clear_inputs() -> void:
	input_array.clear()
	input_array_global.clear()

func clear_outputs() -> void:
	output_array.clear()
	output_array_global.clear()

func num_inputs() -> int:
	return len(input_array)

func num_outputs() -> int:
	return len(output_array)

func get_input(index: int) -> MachineIO:
	if input_array_global.is_empty():
		for io in input_array:
			input_array_global.append(MachineIO.new(io.from + discrete_position, io.to + discrete_position))
	return input_array_global[index]

func get_output(index: int) -> MachineIO:
	if output_array_global.is_empty():
		for io in output_array:
			output_array_global.append(MachineIO.new(io.from + discrete_position, io.to + discrete_position))
	return output_array_global[index]


func get_relative_direction(from: Vector2i, to: Vector2i) -> int:
	var diff = to - from
	if diff == Vector2i.UP:
		return 0
	elif diff == Vector2i.RIGHT:
		return 1
	elif diff == Vector2i.DOWN:
		return 2
	elif diff == Vector2i.LEFT:
		return 3
	return -1


func unregister_self() -> void:
	# Assume that all machines are instantiated as children of MachineManager
	var parent = get_parent().get_parent()
	if parent is MachineManager:
		parent = parent as MachineManager
		parent.unregister_machine(self)
	else:
		printerr("Cannot unregister improperly parented machine: ", get_class())
