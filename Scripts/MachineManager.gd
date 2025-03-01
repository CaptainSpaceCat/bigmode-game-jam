extends Node

class_name MachineManager

# Dictionary to store machines by their position
var machine_map: Dictionary = {}
# Dict to store all active machines that need to be processed
var active_machines: Dictionary = {}

var cumulative_time: float = 0
@export var tick_interval: float = 1
const GRID_SIZE = 16
@onready var machineParent: Node2D = $MachineParent
@onready var animationTimer: Timer = $AnimationTimer

var is_updating: bool = false

func _ready():
	# go through all existing machines and register them
	for child in machineParent.get_children():
		if child is Machine:
			child = child as Machine
			var grid_pos = snap_to_grid(child.global_position)
			child.discrete_position = grid_pos
			register_machine(grid_pos, child)
	
	# start the timer ticking!
	animationTimer.timeout.connect(_trigger_animation_tick)
	animationTimer.start(tick_interval)

func _trigger_animation_tick():
	if is_updating:
		printerr("Attempting next update tick before previous update complete!")
	update_all_machines()
	GlobalSignals.animation_tick.emit()
	

func add_machine_child(m: Machine) -> void:
	machineParent.add_child(m)

# Register a machine at a specific position
func register_machine(pos: Vector2i, machine: Machine) -> void:
	var bounds = machine.discrete_shape
	for x in range(bounds.x):
		for y in range(bounds.y):
			var key = pos + Vector2i(x, y)
			machine_map[key] = machine

# Unregister a specific machine
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

var update_stack: Array[Machine] = []

func update_all_machines() -> void:
	is_updating = true
	update_stack.clear()
	
	for m in machine_map.values():
		if not m:
			continue
		m.update_flag = true
	
	# Evaluate the state of the machines
	for m: Machine in machine_map.values():
		if not m:
			continue
		
		if m.update_flag:
			m.update_flag = false
			update_stack.append(m)
		else:
			continue
		
		
		while len(update_stack) > 0:
			# peek at the top of the stack
			var machine: Machine = update_stack[len(update_stack)-1]
			var recur_flag = false
			for i in range(machine.num_outputs()):
				var io = machine.get_output(i)
				# for each machine output
				# see if there's a corresponding input
				# if so, add that machine to the stack before this one
				var other_machine = machine_map.get(io.to)
				if other_machine and other_machine.update_flag and other_machine.can_accept_input(io.from, io.to):
					other_machine.update_flag = false
					update_stack.append(other_machine)
					recur_flag = true
			# if we did NOT add this machine's outputs to the stack,
			# we can pop and evaluate this machine
			if not recur_flag:
				update_stack.pop_back().perform_cycle(machine_map)
			
	# Mark the machine manager as no longer updating
	is_updating = false
