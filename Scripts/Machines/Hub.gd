class_name Hub
extends Machine

@export var inputBuffers: Array[LetterBuffer]
@onready var machineManager: MachineManager = get_node("/root/Main Scene/MachineManager")
@onready var machineCursor: MachineCursor = get_node("/root/Main Scene/MachineCursor")
@export var inventoryUI: InventoryUI
@export var textLabel: RichTextLabel
@export var progressBar: Sprite2D
@export var ringAnchor: Node2D
@export var expandingRingPrefab: PackedScene = preload("res://Prefabs/expanding_ring.tscn")

@onready var progress_complete_sound: SoundPool = $ProgressSound
@onready var ding_sound: SoundPool = $DingSound

var shader : ShaderMaterial
var current_progress: float = 0

@export var cameraBoundsStage2: CollisionShape2D

var goal_word_data: Array = [
	#word, goal count, cycles per loss
	["COPPER", 20, 1000000],
	["IRON", 15, 25],
	["CRONY", 20, 20],
	["NOPE", 30, 20],
	["POWER", 50, 10],
	["VICTORY", 1000000, 1000000]
]
var current_goal_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	shader = progressBar.material
	#discrete_position = machineManager.snap_to_grid(global_position)
	discrete_shape = Vector2i(3, 4)
	is_destructible = false # don't let the player destroy the hub lol
	#machineManager.register_machine(discrete_position, self)
	display_word(goal_word_data[0][0])

	# top side
	self.add_input(Vector2i(0,-1), Vector2i(0,0))
	self.add_input(Vector2i(1,-1), Vector2i(1,0))
	self.add_input(Vector2i(2,-1), Vector2i(2,0))
	# right
	self.add_input(Vector2i(3,0), Vector2i(2,0))
	self.add_input(Vector2i(3,1), Vector2i(2,1))
	self.add_input(Vector2i(3,2), Vector2i(2,2))
	self.add_input(Vector2i(3,3), Vector2i(2,3))
	# bottom
	self.add_input(Vector2i(2,4), Vector2i(2,3))
	self.add_input(Vector2i(1,4), Vector2i(1,3))
	self.add_input(Vector2i(0,4), Vector2i(0,3))
	# left
	self.add_input(Vector2i(-1,3), Vector2i(0,3))
	self.add_input(Vector2i(-1,2), Vector2i(0,2))
	self.add_input(Vector2i(-1,1), Vector2i(0,1))
	self.add_input(Vector2i(-1,0), Vector2i(0,0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shader.set_shader_parameter("progress", current_progress)

func send_letter_to_channel(channel: int, letter: Letter) -> bool:
	if channel >= 0 and channel < len(inputBuffers):
		return inputBuffers[channel].try_append(letter)
	return false

func perform_cycle(machine_map: Dictionary) -> void:
	var word_data = goal_word_data[current_goal_index]
	var loss: float = 1.0/(word_data[2] * word_data[1])
	current_progress = clampf(current_progress - loss, 0, 2)
	for buf in inputBuffers:
		if buf.is_full:
			var word = buf.pop_serialize().reverse()
			#print("HUB recieved word: ", word)
			if word == word_data[0]:
				ding_sound.play_sound()
				current_progress += 1.0/word_data[1]

	# Check for endgame
	if current_goal_index >= len(goal_word_data) - 1:
		current_progress = 1.1
		return

	if current_progress >= 1:
		# play the progress sound effect
		progress_complete_sound.play_sound()
		# emit an expanding ring on level completion
		var emit_ring = expandingRingPrefab.instantiate()
		add_child(emit_ring)
		emit_ring.global_position = ringAnchor.global_position
		
		# reset progress
		current_progress = 0
		current_goal_index += 1
		display_word(goal_word_data[current_goal_index][0])
		if current_goal_index == 1:
			# set the camera bounds to stage 2
			var active_camera = get_viewport().get_camera_2d()
			active_camera.change_bounds(cameraBoundsStage2)
			
			# unlock slicer and trash bin
			machineCursor.unlock_machine(3)
			machineCursor.unlock_machine(5)
		elif current_goal_index == 2:
			pass
			# unlock merger and combiner
			machineCursor.unlock_machine(1)
			machineCursor.unlock_machine(4)
	
	# Check for endgame again to keep the progress bar full for the next tick
	# a bit jank tbh
	if current_goal_index >= len(goal_word_data) - 1:
		current_progress = 1.1

func get_held_items() -> Array:
	var items = []
	for buf in inputBuffers:
		for item in buf.get_held_items():
			items.append(item)
	return items

func display_word(word: String):
	var text = "[center]" + word + "[/center]"
	#textLabel.clear()
	textLabel.bbcode_enabled = true
	#textLabel.add_text(text)
	textLabel.text = text
