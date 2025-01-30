class_name WordSlicer
extends Machine

@export var inputSlotA: Node2D
@export var outputSlotA: Node2D
@export var outputSlotB: Node2D

func _init():
	self.discrete_shape = Vector2i(2,1)
	self.add_input(Vector2i(-1,0), Vector2i(0,0))
	self.add_output(Vector2i(1,0), Vector2i(2,0))
	self.add_output(Vector2i(1,0), Vector2i(1,1))


var input_buffer: String = ""
var output_buffer: String = ""
var blocked: bool = false
var output_index: int = 0

var slice_index = 1

var letter_in_input: Letter


func send_letter_to_channel(channel: int, letter: Letter) -> bool:
	if channel == 0 && !blocked:
		if letter.content == "": # EOF
			if len(output_buffer) > 0:
				blocked = true
			else:
				output_buffer = input_buffer
				input_buffer = ""
		else:
			input_buffer += letter.content
		letter.send_to(inputSlotA.global_position)
		
		# kinda jank way of deleting the letter after it enters the machine
		if letter_in_input != null:
			letter_in_input.queue_free()
		letter_in_input = letter
		return true
	return false


func perform_cycle(machine_map: Dictionary) -> void:
	if len(output_buffer) > 0:
		# Choose the next letter to output
		var l = "" # Defaults to EOF
		if output_index >= len(output_buffer):
			if blocked:
				output_buffer = input_buffer
				input_buffer = ""
				blocked = false
			else:
				output_buffer = ""
		else:
			l = output_buffer[output_index]
			
		var output_choice = 0
		var output_pos = outputSlotA.global_position
		if output_index >= slice_index:
			output_choice = 1
			output_pos = outputSlotB.global_position
			
		var new_letter: Letter = self.create_letter(l, output_pos)
		print(new_letter)
		if try_send_to_output(machine_map, new_letter, output_choice):
			output_index += 1
		else:
			new_letter.queue_free()


func try_send_to_output(machine_map: Dictionary, letter: Letter, index: int = 0) -> bool:
	var io: MachineIO = self.get_output(index)
	if io.to in machine_map.keys():
		var other_machine: Machine = machine_map[io.to]
		if other_machine.can_accept_input(io.from, io.to):
			return other_machine.try_accept_input(io.from, io.to, letter)
	return false
				
