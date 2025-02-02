class_name ClosedWall
extends Machine

@export var inputBufferA: LetterBuffer
@export var cameraBoundsStage3: CollisionShape2D

@onready var fail_sound: SoundPool = $FailSound
@onready var succeed_sound: SoundPool = $SucceedSound

# Called when the node enters the scene tree for the first time.
func _ready():
	self.discrete_shape = Vector2i(2, 3)
	self.add_input(Vector2i(2,1), Vector2i(1,1))
	
	# dummy outputs for correct door deletion ordering
	self.add_output(Vector2i.ZERO, Vector2i.UP)
	self.add_output(Vector2i(0,2), Vector2i(0,3))

func perform_cycle(machine_map: Dictionary) -> void:
	if inputBufferA.is_full:
		var word = inputBufferA.pop_serialize().reverse()
		if word == "OPEN":
			succeed_sound.play_sound()
			for offset in [Vector2i.UP, Vector2i.DOWN*3]:
				var m = machine_map.get(discrete_position + offset)
				if m != null and m is WallChunk:
					m.mark_for_delete()
			get_viewport().get_camera_2d().change_bounds(cameraBoundsStage3)
			unregister_self()
			queue_free()
		else:
			fail_sound.play_sound()

func send_letter_to_channel(channel: int, letter: Letter) -> bool:
	if channel == 0:
		return inputBufferA.try_append(letter)
	return false
