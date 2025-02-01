class_name Hub
extends Machine

@export var inputBuffers: Array[LetterBuffer]
@onready var machineManager: MachineManager = get_node("/root/Main Scene/MachineManager")
@export var progressBar: Sprite2D
var shader : ShaderMaterial
var current_progress: float = 0

@export var cameraBoundsStage2: CollisionShape2D

var goal_word_data: Array = [
	#word, goal count, cycles per loss
	["COPPER", 10, 30],
	["IRON", 20, 25],
	["CRONY", 10, 20],
	["PEON", 10, 15],
	["POWER", 30, 10],
]
var current_goal_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	shader = progressBar.material
	discrete_position = machineManager.snap_to_grid(global_position)
	discrete_shape = Vector2i.ONE * 3
	is_destructible = false # don't let the player destroy the hub lol
	machineManager.register_machine(discrete_position, self)

	# top side
	self.add_input(Vector2i(0,-1), Vector2i(0,0))
	self.add_input(Vector2i(1,-1), Vector2i(1,0))
	self.add_input(Vector2i(2,-1), Vector2i(2,0))
	# right
	self.add_input(Vector2i(3,0), Vector2i(2,0))
	self.add_input(Vector2i(3,1), Vector2i(2,1))
	self.add_input(Vector2i(3,2), Vector2i(2,2))
	# bottom
	self.add_input(Vector2i(2,3), Vector2i(2,2))
	self.add_input(Vector2i(1,3), Vector2i(1,2))
	self.add_input(Vector2i(0,3), Vector2i(0,2))
	# left
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
				current_progress += 1.0/word_data[1]

	if current_progress >= 1:
		current_progress = 0
		current_goal_index += 1
		if current_goal_index == 1:
			# set the camera bounds to stage 2
			var active_camera = get_viewport().get_camera_2d()
			active_camera.change_bounds(cameraBoundsStage2)
			
			# TODO unlock slicer and trash bin
		elif current_goal_index == 2:
			pass
			# TODO unlock merger
	
	# Check for endgame
	if current_goal_index >= len(goal_word_data):
		print("You beat the game!!!")

func get_held_items() -> Array:
	var items = []
	for buf in inputBuffers:
		for item in buf.get_held_items():
			items.append(item)
	return items
