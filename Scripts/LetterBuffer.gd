class_name LetterBuffer
extends Node2D


var content: String = ""
var is_full: bool = false
var queue_delete: Letter
var letterPrefab: PackedScene = preload("res://Prefabs/letter.tscn")
@onready var itemParent: Node2D = get_node("/root/Main Scene/ItemManager")

# Appends the provided letter to the end of the buffer
# Returns success state
func try_append(letter: Letter) -> bool:
	var l = letter.content
	if len(l) <= 1 and not is_full:
		# Clear the previously saved letter
		if queue_delete != null:
			queue_delete.queue_free()
		
		if len(l) == 1:
			content += l
			letter.send_to(global_position)
			queue_delete = letter
			# Play a sound for this input, if we have one
			try_play_sound()
		if len(l) == 0: # Check for EOF
			is_full = true
			# Free the EOF letter now to avoid having to wait a cycle or more
			letter.queue_free()
			queue_delete = null
		return true
	return false

# Sets the buffer to the provided string, if the buffer is empty
# Returns success state
func try_apply_string(word: String) -> bool:
	if is_full:
		return false
	content = word
	if len(content) > 0:
		is_full = true
	return true

func count() -> int:
	return len(content)
var held_letter: Letter

func clear_self() -> void:
	if held_letter != null:
		held_letter.queue_free()
	if queue_delete != null:
		queue_delete.queue_free()
	content = ""
	is_full = false

# Pops the first character out of the buffer and stores it in held_letter
func dequeue_to_hand():
	if held_letter == null:
		if self.count() > 0:
			var l = content[0]
			content = content.substr(1)
			if l != " ": # Adding space characters to the buffer will force it to skip machine ticks
				# Play a sound for this output
				try_play_sound()
				# Create the letter
				var letter: Letter = letterPrefab.instantiate()
				letter.set_letter(l)
				letter.global_position = global_position
				itemParent.add_child(letter)
				held_letter = letter
		else:
			var letter: Letter = letterPrefab.instantiate() # EOF
			letter.global_position = global_position
			itemParent.add_child(letter)
			held_letter = letter
			is_full = false

func clear_held_letter():
	held_letter = null

# Pops the full string out of the buffer and returns it
func pop_serialize() -> String:
	var out = content
	content = ""
	is_full = false
	return out

func get_held_items() -> Array:
	var items = []
	if held_letter != null:
		items.append(held_letter)
	if queue_delete != null:
		items.append(queue_delete)
	return items

func try_play_sound() -> bool:
	if has_node("SoundPool"):
		var sound_pool = $SoundPool as SoundPool
		sound_pool.play_sound()
		return true
	return false
