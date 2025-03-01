extends Node2D

class_name Letter

var content := "" # Defaults to "", the EOF object for words
@export var text_label: Label

var goal_position: Vector2
@onready var notifier := $VisibleOnScreenNotifier2D


func _ready():
	goal_position = global_position
	notifier.screen_entered.connect(_on_screen_entered)
	notifier.screen_exited.connect(_on_screen_exited)

func _on_screen_entered():
	text_label.show()  # Show when on screen

func _on_screen_exited():
	text_label.hide()  # Hide when off screen

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
