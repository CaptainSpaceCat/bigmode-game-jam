class_name LightbulbMachine
extends Machine

@export var modeOff: Node2D
@export var modeOn: Node2D

@export var inputBufferA: LetterBuffer

@onready var on_sound: SoundPool = $OnSound
#@onready var off_sound: SoundPool = $OffSound
@onready var fail_sound: SoundPool = $FailSound

func _init():
	self.discrete_shape = Vector2i(1, 3)
	self.add_input(Vector2i(0,3), Vector2i(0,2))
	self.is_destructible = false


func perform_cycle(machine_map: Dictionary) -> void:
	if inputBufferA.is_full:
		var word = inputBufferA.pop_serialize().reverse()
		if word == "ON":
			on_sound.play_sound()
			modeOff.visible = false
			modeOn.visible = true
		elif word == "OFF":
			#off_sound.play_sound()
			modeOff.visible = true
			modeOn.visible = false
		else:
			fail_sound.play_sound()

func send_letter_to_channel(channel: int, letter: Letter) -> bool:
	if channel == 0:
		return inputBufferA.try_append(letter)
	return false
