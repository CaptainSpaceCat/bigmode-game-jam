class_name WordSlicer
extends Machine

@export var bufferInA: LetterBuffer
@export var bufferOutA: LetterBuffer
@export var bufferOutB: LetterBuffer
@export var bufferOutC: LetterBuffer

var chosen_output_B: LetterBuffer

@export var numberLabel: RichTextLabel
@export var modeA: Node2D
@export var modeB: Node2D

var slice_index = 1

func _ready():
	chosen_output_B = bufferOutB

func _init():
	self.discrete_shape = Vector2i(2,1)
	self.add_input(Vector2i(-1,0), Vector2i(0,0))
	self.add_output(Vector2i(1,0), Vector2i(2,0))
	self.add_output(Vector2i(1,0), Vector2i(1,1))
	self.add_output(Vector2i(1,0), Vector2i(1,-1))
	self.unlocked_by_default = false


func send_letter_to_channel(channel: int, letter: Letter) -> bool:
	if channel == 0:
		return bufferInA.try_append(letter)
	return false

func set_slice_index(index: int):
	slice_index = clampi(index, 1, 9)
	numberLabel.clear()
	numberLabel.add_text(str(slice_index))


func perform_cycle(machine_map: Dictionary) -> void:
	#print("input buffer: " + input_buffer + ", output buffer: " + output_buffer)
	if bufferInA.is_full and not (bufferOutA.is_full or chosen_output_B.is_full):
		var word = bufferInA.pop_serialize()
		var effective_slice_index = clampi(slice_index, 1, len(word)-1)
		var slice_A = word.substr(len(word) - effective_slice_index)
		var slice_B = word.substr(0, len(word) - effective_slice_index)
		# Prepend spaces to slice_B equal to the number of letters in slice_A
		# This will cause the B output buffer to wait that number of machine ticks before outputting
		slice_B = " ".repeat(len(slice_A)) + slice_B
		bufferOutA.try_apply_string(slice_A)
		chosen_output_B.try_apply_string(slice_B)

	process_output_buffer(machine_map, 0, bufferOutA)
	process_output_buffer(machine_map, 1, bufferOutB)
	process_output_buffer(machine_map, 2, bufferOutC)

func get_held_items() -> Array:
	var items = []
	for item in bufferInA.get_held_items():
		items.append(item)
	for item in bufferOutA.get_held_items():
		items.append(item)
	for item in bufferOutB.get_held_items():
		items.append(item)
	return items

var flipped: bool = false
func handle_key_press(key: int):
	if key == KEY_UP:
		set_slice_index(slice_index+1)
	elif key == KEY_DOWN:
		set_slice_index(slice_index-1)
	if key == KEY_T:
		flipped = !flipped
		# clear whichever outut buffer we have as the secondary output
		# since that's the one that's changing
		# set the chosen output buffer to the correct one, depending on flip state
		var old_output = chosen_output_B
		if flipped:
			chosen_output_B = bufferOutC
		else:
			chosen_output_B = bufferOutB
		
		# Move the contents of the output buffer to the new output buffer
		chosen_output_B.try_apply_string(old_output.pop_serialize())
		old_output.clear_self()
		old_output.is_full = true # jank way of getting it to spit out an extra EOF for the word it just cut off
		animate_flip()


func animate_flip():
	modeA.visible = !flipped
	modeB.visible = flipped
	modeA.scale = Vector2.ONE * 1.1
	modeB.scale = Vector2.ONE * 1.1
	create_tween().tween_property(modeA, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_QUAD)
	create_tween().tween_property(modeB, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_QUAD)
	
