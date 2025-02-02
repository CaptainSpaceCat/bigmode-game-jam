class_name WordMerger
extends Machine


@export var bufferInA: LetterBuffer
@export var bufferInB: LetterBuffer
@export var bufferOutA: LetterBuffer

@export var modeA: Node2D
@export var modeB: Node2D

var flipped: bool = false

func _init():
	self.discrete_shape = Vector2i(1,2)
	self.add_input(Vector2i(-1,0), Vector2i(0,0))
	self.add_input(Vector2i(-1,1), Vector2i(0,1))
	self.add_output(Vector2i(0,0), Vector2i(1,0))
	self.unlocked_by_default = false


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
		var out_string = segmentB + segmentA
		if flipped:
			out_string = segmentA + segmentB
		bufferOutA.try_apply_string(out_string)
	
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


func handle_key_press(key: int):
	if key == KEY_T:
		flipped = !flipped
		animate_flip()

func animate_flip():
	modeA.visible = !flipped
	modeB.visible = flipped
	modeA.scale = Vector2.ONE * 1.1
	modeB.scale = Vector2.ONE * 1.1
	create_tween().tween_property(modeA, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_QUAD)
	create_tween().tween_property(modeB, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_QUAD)
	
