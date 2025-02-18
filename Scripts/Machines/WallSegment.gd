class_name WallChunk
extends Machine

var delete_next_cycle: bool = false

@export var flipped: bool = false
@onready var soundPool: SoundPool = $SoundPool

func _ready():
	# dummy IOs for correct door deletion ordering
	if flipped:
		self.add_input(Vector2i.UP, Vector2i.ZERO)
		self.add_output(Vector2i.ZERO, Vector2i.DOWN)
	else:
		self.add_input(Vector2i.DOWN, Vector2i.ZERO)
		self.add_output(Vector2i.ZERO, Vector2i.UP)

func _init() -> void:
	self.discrete_shape = Vector2i(2,1)
	self.is_destructible = false
	

func perform_cycle(machine_map: Dictionary) -> void:
	if delete_next_cycle:
		# Mark any neighboring wall segments for deletion next cycle
		var m = machine_map.get(get_output(0).to)
		if m != null and m is WallChunk:
			m.mark_for_delete()
		unregister_self()
		shrink_and_free()

func mark_for_delete() -> void:
	delete_next_cycle = true
	soundPool.play_sound()
