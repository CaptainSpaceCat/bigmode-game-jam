class_name BeltMerger
extends Machine


@export var bufferInA: LetterBuffer
@export var bufferInB: LetterBuffer
@export var bufferOutA: LetterBuffer

var priority_flipped: bool = false

func _init():
	self.discrete_shape = Vector2i(1,2)
	self.add_input(Vector2i(-1,0), Vector2i(0,0))
	self.add_input(Vector2i(-1,1), Vector2i(0,1))
	self.add_output(Vector2i(0,1), Vector2i(1,1))
	self.unlocked_by_default = false


func perform_cycle(machine_map: Dictionary):
	if not bufferOutA.is_full:
		if priority_flipped:
			if bufferInA.is_full:
				bufferOutA.try_apply_string(bufferInA.pop_serialize())
				priority_flipped = !priority_flipped
			elif bufferInB.is_full:
				bufferOutA.try_apply_string(bufferInB.pop_serialize())
				priority_flipped = !priority_flipped
		else:
			if bufferInB.is_full:
				bufferOutA.try_apply_string(bufferInB.pop_serialize())
				priority_flipped = !priority_flipped
			elif bufferInA.is_full:
				bufferOutA.try_apply_string(bufferInA.pop_serialize())
				priority_flipped = !priority_flipped
	
	process_output_buffer(machine_map, 0, bufferOutA)

func get_held_items() -> Array:
	var items = []
	for item in bufferInA.get_held_items():
		items.append(item)
	for item in bufferInB.get_held_items():
		items.append(item)
	for item in bufferOutA.get_held_items():
		items.append(item)
	return items

func send_letter_to_channel(channel: int, letter: Letter) -> bool:
	if channel == 0:
		return bufferInA.try_append(letter)
	if channel == 1:
		return bufferInB.try_append(letter)
	return false
