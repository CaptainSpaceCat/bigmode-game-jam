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
		#print("Recieved letter: ", letter.content)
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
	#print("input buffer: " + input_buffer + ", output buffer: " + output_buffer)
	# Choose the next letter to output
	var l = "" # Defaults to EOF
	if len(output_buffer) > 0:
		if output_index >= len(output_buffer):
			if blocked:
				output_buffer = input_buffer
				input_buffer = ""
				blocked = false
			else:
				var eof = self.create_letter("", outputSlotA.global_position)
				if not self.try_send_letter(machine_map, eof, 1):
					# if we happen to fail to send out the EOF, this will block the machine, so we must return
					return
				
				output_buffer = ""
				output_index = 0
				
		else:
			l = output_buffer[output_index]
	
	if len(output_buffer) > 0: # if it's still 0 after the above check
		# Default to output A
		var output_choice = 0
		var output_pos = outputSlotA.global_position
		if output_index == len(output_buffer) - slice_index:
			# edge case where we are, this tick, sending the next letter to output B
			# IE we have just begun the slice
			# in this situation, we need to also send out another EOF letter to output A on the same tick
			var eof = self.create_letter("", outputSlotA.global_position)
			if not self.try_send_letter(machine_map, eof, 0):
				# if we happen to fail to send out the EOF, this will block the machine, so we must return
				return
		# If we're past the slice, send to output B
		if output_index >= len(output_buffer) - slice_index:
			output_choice = 1
			output_pos = outputSlotB.global_position
			
		var new_letter: Letter = self.create_letter(l, output_pos)
		if try_send_letter(machine_map, new_letter, output_choice):
			output_index += 1


func try_send_letter(machine_map: Dictionary, new_letter: Letter, output_channel: int) -> bool:
	if self.try_send_to_output(machine_map, new_letter, output_channel):
		return true
	new_letter.queue_free()
	return false
