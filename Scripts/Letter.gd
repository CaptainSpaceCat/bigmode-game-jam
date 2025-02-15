extends Node2D

class_name Letter

var content: String = "" # Defaults to "", the EOF object for words
@export var text_label: Label
@onready var machineManager: MachineManager = get_node("/root/Main Scene/MachineManager")

var goal_position: Vector2

func _ready():
	goal_position = global_position
	GlobalSignals.animation_tick.connect(_on_animation_tick)
	
	# Start with the letter as invisible
	# The first animation tick it recieves will enable it
	#visible = false

func set_letter(content: String) -> void:
	if len(content) >= 1:
		self.content = content[0]
		self.text_label.text = self.content

func _to_string() -> String:
	return content

func value() -> String:
	if len(self.content) > 1:
		return self.content[0]
	return self.content

func send_to(pos: Vector2i) -> void:
	# TODO: instead, store a goal position here,
	# then wait for global anim_tick signal and create the tween then
	# this way we can streamline / multithread the backend, and have the frontend update on a tick
	goal_position = pos


func _exit_tree():
	GlobalSignals.animation_tick.disconnect(_on_animation_tick)

func _on_animation_tick():
	if not visible:
		visible = true
	else:
		var tween = create_tween()
		tween.tween_property(self, "global_position", Vector2(goal_position), machineManager.tick_interval).set_trans(Tween.TRANS_QUAD)
