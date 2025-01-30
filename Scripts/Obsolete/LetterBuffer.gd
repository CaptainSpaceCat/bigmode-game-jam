extends Node2D

class_name LetterBuffer

var letters: Array = []
var blocked: bool = false
@export var direction: int = 0
@export var capacity: int = 1

var output_position: Vector2i


func try_append(l: Letter) -> bool:
	if !blocked:
		letters.append(l)
		if self.count() == capacity:
			blocked = true
		return true
	return false


func count() -> int:
	return len(self.letters)


func dequeue() -> Letter:
	var l = ""
	if self.count() > 0:
		l = letters[0]
		letters.remove_at(0)
	return l
