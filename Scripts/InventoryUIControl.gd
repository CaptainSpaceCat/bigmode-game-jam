class_name InventoryUI
extends Node

@export var highlightTexture: TextureRect
@export var slotLabel: Label
@export var slotTextures: Array[TextureRect]


const slot_names = ["Conveyer", "Miner", "Slicer", "Merger", "Trash"]

func set_selected_slot(slot: int):
	if slot >= 0 and slot < len(slotTextures):
		highlightTexture.visible = true
		highlightTexture.position.x = -164 + 64 * slot
		slotLabel.text = slot_names[slot]
	else:
		highlightTexture.visible = false
		slotLabel.text = ""
		

func set_slot_enabled(slot: int, state: bool):
	slotTextures[slot].modulate.a = 1 if state else 0
