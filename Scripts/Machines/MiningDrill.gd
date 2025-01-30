class_name MiningDrill
extends Machine

@export var generate_pos: Node2D

func _init():
	self.discrete_shape = Vector2i.ONE*2
	self.add_output(Vector2i(1,0), Vector2i(2,0))
	
var word: String = "COPPER"
var index: int = 0
var post_delay_cycles: int = 8

func set_word(new_word: String):
	self.word = new_word

func perform_cycle(machine_map: Dictionary) -> void:
	var io: MachineIO = self.get_output(0)
	if io.to in machine_map.keys():
		var other_machine: Machine = machine_map[io.to]
		if other_machine.can_accept_input(io.from, io.to):
			# create a new letter object
			var letter: Letter = letterPrefab.instantiate()
			# Choose the letter
			# TODO make this pull from the ores layer
			if index >= 0 and index < len(word):
				var l = word[len(word) - index - 1]
				letter.set_letter(l)
			elif index == len(word):
				pass # do nothing, the letter object is EOF by default so it'll get sent properly
			elif index < len(word) + post_delay_cycles:
				# if we've fully finished the word, and we're still in the delay cycles,
				# do nothing and skip to the next cycle
				index += 1
				return
			else:
				# if we've exhausted the delay cycles, set index back to 0
				index = 0
				return
				
			# If we made it this far, set the new letter's initial position
			letter.global_position = generate_pos.global_position
			# Add to scene tree, parented to the ItemManager node
			get_item_parent().add_child(letter)
			
			if other_machine.try_accept_input(io.from, io.to, letter):
				index += 1
			else:
				# TODO make the letter just sit there until there's space for it to move,
				# rather than repeatedly creating and destroying them until there's space
				letter.queue_free()
			
