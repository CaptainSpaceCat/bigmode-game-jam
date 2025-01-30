extends Object

class_name MachineIO

# world grid position of this machine IO
var from: Vector2i
# the world grid pos of this IO operation
var to: Vector2i


func _init(f: Vector2i, t: Vector2i):
	from = f
	to = t
