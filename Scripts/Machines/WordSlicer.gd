class_name WordSlicer
extends Machine

@export var bufferInA: LetterBuffer
@export var bufferOutA: LetterBuffer
@export var bufferOutB: LetterBuffer

@export var numberLabel: Label
@export var modeA: Node2D
@export var modeB: Node2D

var slice_index = 1


func _init():
	self.discrete_shape = Vector2i(1,2)
	self.add_input(Vector2i(-1,0), Vector2i(0,0))
	self.add_output(Vector2i(0,0), Vector2i(1,0))
	self.add_output(Vector2i(0,1), Vector2i(1,1))
	self.unlocked_by_default = false


func send_letter_to_channel(channel: int, letter: Letter) -> bool:
	if channel == 0:
		return bufferInA.try_append(letter)
	return false

func set_slice_index(index: int):
	slice_index = clampi(index, 1, 9)
	numberLabel.text = str(slice_index)


func perform_cycle(machine_map: Dictionary) -> void:
	if bufferInA.is_full and not (bufferOutA.is_full or bufferOutB.is_full):
		var word = bufferInA.pop_serialize()
		var effective_slice_index = clampi(slice_index, 1, len(word))
		var slice_A = word.substr(len(word) - effective_slice_index)
		var slice_B = word.substr(0, len(word) - effective_slice_index)
		# Prepend spaces to slice_A equal to the number of letters in slice_B
		# This will cause the A output buffer to wait that number of machine ticks before outputting
		# Used to make the word look streamlined when split
		slice_A = " ".repeat(len(slice_B)) + slice_A
		if not flipped:
			bufferOutA.try_apply_string(slice_A)
			bufferOutB.try_apply_string(slice_B)
		else:
			bufferOutA.try_apply_string(slice_B)
			bufferOutB.try_apply_string(slice_A)

	process_output_buffer(machine_map, 0, bufferOutA)
	process_output_buffer(machine_map, 1, bufferOutB)

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
		# swap the contents of the output buffers
		var temp_string = bufferOutB.pop_serialize()
		bufferOutB.try_apply_string(bufferOutA.pop_serialize())
		bufferOutA.try_apply_string(temp_string)
		
		animate_flip()


func animate_flip():
	modeA.visible = !flipped
	modeB.visible = flipped
	modeA.scale = Vector2.ONE * 1.1
	modeB.scale = Vector2.ONE * 1.1
	create_tween().tween_property(modeA, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_QUAD)
	create_tween().tween_property(modeB, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_QUAD)
	
