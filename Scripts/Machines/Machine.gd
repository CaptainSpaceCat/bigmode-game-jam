class_name Machine
extends Node2D

var update_flag: bool = false
var discrete_position: Vector2i  # World grid position of the machine
var discrete_shape: Vector2i = Vector2i.ONE # Width and height of the machine
var locked_by_default: bool = false
var letterPrefab: PackedScene = preload("res://Prefabs/letter.tscn")


# Check whether the inserted IO will be accepted by this machine
func can_accept_input(from: Vector2i, to: Vector2i) -> bool:
	for io in input_array:
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


# This should get overridden in derived classes to customize input channels
func send_letter_to_channel(channel: int, letter: Letter) -> bool:
	return false


func create_letter(l: String, pos: Vector2) -> Letter:
	var letter: Letter = letterPrefab.instantiate()
	letter.set_letter(l)
	letter.global_position = pos
	# Add to scene tree, parented to the ItemManager node
	get_item_parent().add_child(letter)
	return letter


# This should get overridden in derived classes to customize the machine's cycle
func perform_cycle(machine_map: Dictionary) -> void:
	pass

func get_held_items() -> Array:
	return []

# Store and retrieve IO objects

var input_array: Array = []
var output_array: Array = []

func add_input(from: Vector2i, to: Vector2i) -> void:
	input_array.append(MachineIO.new(from, to))

func add_output(from: Vector2i, to: Vector2i) -> void:
	output_array.append(MachineIO.new(from, to))

func clear_inputs() -> void:
	input_array.clear()

func clear_outputs() -> void:
	output_array.clear()

func num_inputs() -> int:
	return len(input_array)

func num_outputs() -> int:
	return len(output_array)

func get_input(index: int) -> MachineIO:
	var local = input_array[index]
	return MachineIO.new(local.from + discrete_position, local.to + discrete_position)

func get_output(index: int) -> MachineIO:
	var local = output_array[index]
	return MachineIO.new(local.from + discrete_position, local.to + discrete_position)


func get_item_parent():
	return get_node("../../ItemManager")
