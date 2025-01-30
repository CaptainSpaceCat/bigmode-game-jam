class_name ConveyerBelt
extends Machine

@export var renderA: Node2D
@export var renderB: Node2D

var slotA: Letter
var slotB: Letter

func _init() -> void:
	self.add_input(Vector2i(-1,0), Vector2i.ZERO)
	self.add_output(Vector2i.ZERO, Vector2i(1,0))

func send_letter_to_channel(channel: int, letter: Letter) -> bool:
	if channel == 0:
		if slotA == null:
			slotA = letter
			slotA.send_to(renderA.global_position)
			return true
	return false


func perform_cycle(machine_map: Dictionary) -> void:
	# try to move item from slot B into the next tile
	if slotB != null:
		var io: MachineIO = super.get_output(0)
		if io.to in machine_map.keys():
			var other_machine: Machine = machine_map[io.to]
			if other_machine.can_accept_input(io.from, io.to):
				if other_machine.try_accept_input(io.from, io.to, slotB):
					slotB = null
					
	# try to move item in slot A to slot B
	if slotA != null:
		if slotB == null:
			slotA.send_to(renderB.global_position)
			slotB = slotA
			slotA = null
