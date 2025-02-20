class_name InventoryUI
extends Node

@export var highlightTexture: TextureRect
@export var slotLabel: Label
@export var slotTextures: Array[TextureRect]

@export var tooltipLabel: Label
@export var alertLabel: Label

@export var alert_duration: float = 5

const slot_names = ["Conveyer", "Merger", "Miner", "Slicer", "Combiner", "Trash"]
const slot_tooltips = [
	"Moves items.\nClick and drag to place.\nRight click and drag to delete.",
	"Combines two belts into one.",
	"Mines out the ore patches on the ground.\nMouse over and press T to rotate.",
	"Cuts word into two after the Nth letter.\nMouse over and use scroll wheel or up/down arrows to change the value of N.\nPress T while mousing over to swap output positions.",
	"Accepts two separate words and glues them together.\nPress T while mousing over to flip the order of gluing.",
	"Trashes any letters you send into it."
	]


func set_selected_slot(slot: int):
	if slot >= 0 and slot < len(slotTextures):
		highlightTexture.visible = true
		highlightTexture.position.x = -196 + 64 * slot
		slotLabel.text = slot_names[slot]
		tooltipLabel.text = slot_tooltips[slot]
	else:
		highlightTexture.visible = false
		slotLabel.text = ""
		tooltipLabel.text = ""
		

func set_slot_enabled(slot: int, state: bool):
	slotTextures[slot].modulate.a = 1 if state else 0


func send_alert(message: String):
	alertLabel.text = message
	var tween = create_tween()
	tween.tween_property(alertLabel, "position", Vector2.ZERO, 1).set_trans(Tween.TRANS_QUAD)
	tween.connect("finished", Callable(self, "clear_alert"))

func clear_alert():
	var tween = create_tween()
	tween.tween_property(alertLabel, "position", Vector2.UP*200, 1).set_trans(Tween.TRANS_QUAD).set_delay(alert_duration)

'''
var queued_alerts: Array[String] = []

#TODO send the message to the alert label, animate showing it and removing it
func show_alert(message: String):
	queued_alerts.append()
'''
