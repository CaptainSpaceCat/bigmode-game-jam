class_name WordMerger
extends Machine


@export var bufferInA: LetterBuffer
@export var bufferInB: LetterBuffer
@export var bufferOutA: LetterBuffer


func _init():
	self.discrete_shape = Vector2i(1,2)
	self.add_input(Vector2i(-1,0), Vector2i(0,0))
	self.add_input(Vector2i(-1,1), Vector2i(0,1))
	self.add_output(Vector2i(0,0), Vector2i(1,0))


func send_letter_to_channel(channel: int, letter: Letter) -> bool:
	if channel == 0:
		return bufferInA.try_append(letter)
	if channel == 1:
		return bufferInB.try_append(letter)
	return false


func perform_cycle(machine_map: Dictionary) -> void:
	if (bufferInA.is_full and bufferInB.is_full) and not bufferOutA.is_full:
		var segmentA = bufferInA.pop_serialize()
		var segmentB = bufferInB.pop_serialize()
		bufferOutA.try_apply_string(segmentB + segmentA)
	
	process_output_buffer(machine_map, 0, bufferOutA)


func get_held_items() -> Array:
	if bufferOutA.held_letter != null:
		return [bufferOutA.held_letter]
	return []
