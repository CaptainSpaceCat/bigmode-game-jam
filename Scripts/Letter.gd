extends Node2D

class_name Letter

var content: String = "" # Defaults to "", the EOF object for words
@export var text_label: RichTextLabel
@export var text_background: RichTextLabel
const animation_duration: float = 0.5

func set_letter(content: String) -> void:
	if len(content) >= 1:
		self.content = content[0]
		self.text_label.clear()
		self.text_label.add_text(content)
		self.text_background.clear()
		self.text_background.add_text(content)

func _to_string() -> String:
	return content

func value() -> String:
	if len(self.content) > 1:
		return self.content[0]
	return self.content

func send_to(pos: Vector2i) -> void:
	var tween = create_tween()
	tween.tween_property(self, "global_position", Vector2(pos), animation_duration).set_trans(Tween.TRANS_QUAD)
