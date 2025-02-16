class_name MiningDrill
extends Machine

@export var generate_pos: Node2D
@export var bufferOutA: LetterBuffer
@export var bufferOutB: LetterBuffer
@export var baseSprite: Sprite2D
@export var particleEmitter: GPUParticles2D

var chosen_output: LetterBuffer

func _ready():
	chosen_output = bufferOutA

func _init():
	self.discrete_shape = Vector2i.ONE*2
	self.add_output(Vector2i(1,0), Vector2i(2,0))
	#self.add_output(Vector2i.ZERO, Vector2i.LEFT)


var word: String = ""
var cycle_index: int = 1000 # Start out ready to dump ores immediately
var delay_cycles: int = 8

func set_word(new_word: String):
	self.word = new_word

func perform_cycle(machine_map: Dictionary) -> void:
	if cycle_index >= len(word):
		particleEmitter.emitting = false
	
	# Send a new word to the output every n cycles
	# Suspend if the output is blocked
	if cycle_index >= len(word) + delay_cycles:
		if chosen_output.try_apply_string(word.reverse()):
			cycle_index = 0
			particleEmitter.emitting = true
	cycle_index += 1
	
	process_output_buffer(machine_map, 0, bufferOutA)
	#process_output_buffer(machine_map, 1, bufferOutB)

func get_held_items() -> Array:
	var items = []
	for item in bufferOutA.get_held_items():
		items.append(item)
	for item in bufferOutB.get_held_items():
		items.append(item)
	return items

var flipped: bool = false
'''
func handle_key_press(key: int):
	if key == KEY_T:
		flipped = !flipped
		
		var old_output = chosen_output
		if flipped:
			chosen_output = bufferOutB
		else:
			chosen_output = bufferOutA
		
		# Move the contents of the output buffer to the new output buffer
		chosen_output.try_apply_string(old_output.pop_serialize())
		old_output.clear_self()
		old_output.is_full = true # jank way of getting it to spit out an extra EOF for the word it just cut off
		animate_flip()
'''

func animate_flip():
	baseSprite.flip_h = flipped
	baseSprite.scale = Vector2.ONE * 1.1
	create_tween().tween_property(baseSprite, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_QUAD)
	
