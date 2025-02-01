class_name MiningDrill
extends Machine

@export var generate_pos: Node2D
@export var bufferOutA: LetterBuffer

func _init():
	self.discrete_shape = Vector2i.ONE*2
	self.add_output(Vector2i(1,0), Vector2i(2,0))
	
var word: String = ""
var cycle_index: int = 1000 # Start out ready to dump ores immediately
var delay_cycles: int = 8

func set_word(new_word: String):
	self.word = new_word

func perform_cycle(machine_map: Dictionary) -> void:
	# Send a new word to the output every n cycles
	# Suspend if the output is blocked
	if cycle_index >= len(word) + delay_cycles:
		if bufferOutA.try_apply_string(word.reverse()):
			cycle_index = 0
	cycle_index += 1
	
	process_output_buffer(machine_map, 0, bufferOutA)

func get_held_items() -> Array:
	if bufferOutA.held_letter != null:
		return [bufferOutA.held_letter]
	return []
