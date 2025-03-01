class_name SoundPool
extends Node2D

var sound_pool = []
@export var gain_db = -25
@export var pitch_rescale: float = 1
@export var pool_size = 5  # Max number of simultaneous sounds
@export var SOUND_PATH = "res://Audio/SFX/"  # Replace in editor with the sound path for each machine

@export var global_sound: bool = false

enum SoundMode { RANDOM_PITCH, ASCENDING_PITCH, DESCENDING_PITCH }
@export var mode: SoundMode = SoundMode.RANDOM_PITCH

const ATTENUATION: float = 5
const GAIN_EXTRA: float = 15

func _ready():
	var sound_resource = load(SOUND_PATH)
	if sound_resource == null:
		push_error("Failed to load sound: " + SOUND_PATH)
		return

	for i in range(pool_size):
		var player : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		player.stream = sound_resource
		player.bus = "SFX"
		player.attenuation = 1 if global_sound else ATTENUATION
		add_child(player)
		sound_pool.append(player)

var pitch_mult: float = 1
const MAX_PITCH: float = 1.5
var play_timestamp = 0
var cutoff_time: float = 0.07

func play_sound():
	# drop any calls to play_sound that arrive within the cutoff window of a previous play
	# this prevents extremely rapid and annoying sounds when placing/deleting many machines
	# also helps make the ascending and descending pitch more obvious
	if Time.get_ticks_msec() - play_timestamp >= cutoff_time * 1000:
		for player: AudioStreamPlayer2D in sound_pool:
			if !player.playing:
				match mode:
					SoundMode.RANDOM_PITCH:
						player.pitch_scale = pitch_rescale * randf_range(0.9, 1.1)
					SoundMode.ASCENDING_PITCH:
						player.pitch_scale = pitch_rescale * pitch_mult
						pitch_mult += 0.05
						if pitch_mult > MAX_PITCH:
							reset_pitch()
					SoundMode.DESCENDING_PITCH:
						player.pitch_scale = pitch_rescale * pitch_mult
						pitch_mult -= 0.05
						if pitch_mult < (MAX_PITCH - 1):
							reset_pitch()
				
				player.volume_db = gain_db + GAIN_EXTRA
				play_timestamp = Time.get_ticks_msec()
				player.play(0.0)
				return
		# If no players are available, fall back to the first one (prevents missing sounds)
		play_timestamp = Time.get_ticks_msec()
		sound_pool[0].play()

# for ease of understanding, this can be called from machines needing to manually reset their sound buffers
func reset_pitch():
	pitch_mult = 1
