class_name MiningDrill
extends Machine

@export var generate_pos: Node2D
@export var bufferOutA: LetterBuffer
@onready var baseSpriteNode: Node2D = $ModeA
@export var particleEmitter: GPUParticles2D

func _ready():
	direction = 1
	set_directional_output(direction)

func _init():
	self.discrete_shape = Vector2i.ONE*2

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
		if bufferOutA.try_apply_string(word.reverse()):
			cycle_index = 0
			particleEmitter.emitting = true
	cycle_index += 1
	
	process_output_buffer(machine_map, 0, bufferOutA)
	#process_output_buffer(machine_map, 1, bufferOutB)

func get_held_items() -> Array:
	var items = []
	for item in bufferOutA.get_held_items():
		items.append(item)
	return items

var direction: int = 1
func handle_key_press(key: int):
	if key == KEY_T:
		direction = (direction + 1) % 4
		set_directional_output(direction)
		animate_rotate()
		

func set_directional_output(dir: int):
	self.clear_outputs()
	if dir == 0:
		self.add_output(Vector2i.ZERO, Vector2i.UP)
		bufferOutA.position = Vector2i(0,0)
	elif dir == 1:
		self.add_output(Vector2i(1,0), Vector2i(2,0))
		bufferOutA.position = Vector2i(16,0)
	elif dir == 2:
		self.add_output(Vector2i(1,1), Vector2i(1,2))
		bufferOutA.position = Vector2i(16,16)
	elif dir == 3:
		self.add_output(Vector2i(0,1), Vector2i(-1,1))
		bufferOutA.position = Vector2i(0,16)
	
	# If the output was holding a letter, make sure it moves to the output's new location
	if bufferOutA.held_letter:
		bufferOutA.held_letter.send_to(bufferOutA.global_position)


func animate_rotate():
	if baseSpriteNode:
		baseSpriteNode.rotation = PI/2 * ((direction+3)%4)
		baseSpriteNode.scale = Vector2.ONE * 1.1
		create_tween().tween_property(baseSpriteNode, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_QUAD)
	
