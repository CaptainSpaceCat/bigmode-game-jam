extends Node2D

@onready var machineManager: MachineManager = get_node("/root/Main Scene/MachineManager")

func _ready():
	GlobalSignals.animation_tick.connect(_on_animation_tick)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_animation_tick():
	# check if there are any letters to render
	var letters_to_move := []
	for c in get_children():
		if c is Letter and c.global_position != c.goal_position:
			letters_to_move.append(c as Letter)
	
	# tween ALL the letters at once!
	if not letters_to_move.is_empty():
		var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_parallel(true)
		for letter in letters_to_move:
			tween.tween_property(letter, "position", letter.goal_position, machineManager.tick_interval)
	
