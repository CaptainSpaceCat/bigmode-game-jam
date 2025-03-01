extends Node2D

@onready var machineManager: MachineManager = get_node("/root/Main Scene/MachineManager")

func _ready():
	GlobalSignals.animation_tick.connect(_on_animation_tick)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animation_tick():
	# check if there are any letters to render
	var flag = false
	for c in get_children():
		if c is Letter:
			flag = true
			break
	if not flag:
		return
	
	# tween ALL the letters at once!
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_parallel(true)
	for c in get_children():
		if c is Letter:
			var letter = c as Letter
			tween.tween_property(letter, "position", letter.goal_position, machineManager.tick_interval)
	
