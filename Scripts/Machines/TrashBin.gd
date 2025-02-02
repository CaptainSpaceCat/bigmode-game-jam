class_name TrashBin
extends Machine

@export var inputBuffers: Array[LetterBuffer]

func _init():
	self.add_input(Vector2i.UP, Vector2i.ZERO)
	self.add_input(Vector2i.RIGHT, Vector2i.ZERO)
	self.add_input(Vector2i.DOWN, Vector2i.ZERO)
	self.add_input(Vector2i.LEFT, Vector2i.ZERO)
	self.unlocked_by_default = false

func send_letter_to_channel(channel: int, letter: Letter) -> bool:
	if channel >= 0 and channel < len(inputBuffers):
		return inputBuffers[channel].try_append(letter)
	return false

func perform_cycle(machine_map: Dictionary) -> void:
	for buf in inputBuffers:
		if buf.is_full:
			buf.pop_serialize()
			# do nothing with the popped value, since we're destroying the word

func get_held_items() -> Array:
	var items = []
	for buf in inputBuffers:
		for item in buf.get_held_items():
			items.append(item)
	return items
