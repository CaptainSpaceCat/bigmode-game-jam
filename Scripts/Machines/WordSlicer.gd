class_name WordSlicer
extends Machine

@export var bufferInA: LetterBuffer
@export var bufferOutA: LetterBuffer
@export var bufferOutB: LetterBuffer

var slice_index = 1

func _init():
	self.discrete_shape = Vector2i(2,1)
	self.add_input(Vector2i(-1,0), Vector2i(0,0))
	self.add_output(Vector2i(1,0), Vector2i(2,0))
	self.add_output(Vector2i(1,0), Vector2i(1,1))


func send_letter_to_channel(channel: int, letter: Letter) -> bool:
	if channel == 0:
		return bufferInA.try_append(letter)
	return false


func perform_cycle(machine_map: Dictionary) -> void:
	#print("input buffer: " + input_buffer + ", output buffer: " + output_buffer)
	if bufferInA.is_full and not (bufferOutA.is_full or bufferOutB.is_full):
		var word = bufferInA.pop_serialize()
		var slice_B = word.substr(len(word) - slice_index)
		var slice_A = word.substr(0, len(word) - slice_index)
		# Prepend spaces to slice_B equal to the number of letters in slice_A
		# This will cause the B output buffer to wait that number of machine ticks before outputting
		slice_B = " ".repeat(len(slice_A)) + slice_B
		bufferOutA.try_apply_string(slice_A)
		bufferOutB.try_apply_string(slice_B)

	process_output_buffer(machine_map, 0, bufferOutA)
	process_output_buffer(machine_map, 1, bufferOutB)

func get_held_items() -> Array:
	var items = []
	if bufferOutA.held_letter != null:
		items.append(bufferOutA.held_letter)
	if bufferOutB.held_letter != null:
		items.append(bufferOutB.held_letter)
	return items
