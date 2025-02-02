class_name SoundPool
extends Node2D

var sound_pool = []
@export var gain_db = -25
@export var pitch_rescale: float = 1
@export var pool_size = 5  # Max number of simultaneous sounds
@export var SOUND_PATH = "res://Audio/SFX/"  # Replace in editor with the sound path for each machine

@export var global_sound: bool = false

const ATTENUATION: float = 5
const GAIN_EXTRA: float = 15

func _ready():
	var sound_resource = load(SOUND_PATH)
	if sound_resource == null:
		push_error("Failed to load tick sound: " + SOUND_PATH)
		return

	for i in range(pool_size):
		var player : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		player.stream = sound_resource
		player.bus = "SFX"
		player.attenuation = 1 if global_sound else ATTENUATION
		add_child(player)
		sound_pool.append(player)


func play_sound():
	for player: AudioStreamPlayer2D in sound_pool:
		if !player.playing:
			player.pitch_scale = pitch_rescale * randf_range(0.9, 1.1)  # Random pitch variation
			player.volume_db = gain_db + GAIN_EXTRA
			player.play(0.0)
			return

	# If no players are available, fall back to the first one (prevents missing sounds)
	sound_pool[0].play()
