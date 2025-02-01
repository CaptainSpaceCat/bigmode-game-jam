extends Node

class_name MachineManager

# Dictionary to store machines by their position
var machine_map: Dictionary = {}

var cumulative_time: float = 0
@export var tick_interval: float = 1
const GRID_SIZE = 16

func _process(delta):
	cumulative_time += delta
	if cumulative_time >= tick_interval:
		cumulative_time -= tick_interval
		update_all_machines()

# Register a machine at a specific position
func register_machine(pos: Vector2i, machine: Machine) -> void:
	var bounds = machine.discrete_shape
	for x in range(bounds.x):
		for y in range(bounds.y):
			var key = pos + Vector2i(x, y)
			machine_map[key] = machine

# Unregister a machine from a specific position
func unregister_machine(machine: Machine) -> void:
	var to_remove = []
	for k in machine_map.keys():
		if machine_map[k] == machine:
			to_remove.append(k)
	for pos in to_remove:
		machine_map.erase(pos)

# Get a machine at a specific position
func get_machine(pos: Vector2i) -> Machine:
	return machine_map.get(pos, null)

func is_area_clear(pos: Vector2i, bounds: Vector2i) -> bool:
	for x in range(bounds.x):
		for y in range(bounds.y):
			var key = pos + Vector2i(x, y)
			if key in machine_map.keys():
				return false
	return true

# Snap a global position to the nearest grid index
func snap_to_grid(pos: Vector2) -> Vector2i:
	return Vector2i(
		floor(pos.x / GRID_SIZE),
		floor(pos.y / GRID_SIZE)
	)

func update_all_machines() -> void:
	for m in machine_map.values():
		m.update_flag = true
	
	# Recursively evaluate the state of the machines
	for m in machine_map.values():
		recursive_update(m)


func recursive_update(machine: Machine):
	# If the update flag is false, we have already updated this machine this cycle
	# Thus we return imediately
	if !machine.update_flag:
		return
	# Otherwise, we're about to perform the update to this machine,
	# so set the update flag to false
	machine.update_flag = false
	
	# Perform the recursive update
	for i in range(machine.num_outputs()):
		var io = machine.get_output(i)
		# for each machine output
		# see if there's a corresponding input
		# if so, call recursive_update on that machine
		if io.to in machine_map.keys():
			var other_machine = machine_map[io.to]
			if other_machine.can_accept_input(io.from, io.to):
				recursive_update(other_machine)
	
	# All machines further down the line should be recursively updated by now
	# We now call perform_cycle on this machine
	machine.perform_cycle(machine_map)
