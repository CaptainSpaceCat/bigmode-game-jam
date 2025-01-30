class_name LetterBuffer
extends Object

var letters: Array = []
var capacity: int = 1
var is_empty: bool = true

func _init(cap: int = 1):
	self.capacity = cap

func try_append(l: Letter) -> bool:
	if self.count() < capacity:
		letters.append(l)
		is_empty = false
		return true
	return false

func count() -> int:
	return len(self.letters)

func dequeue() -> Letter:
	if self.count() > 0:
		return letters.pop_at(0)
	else:
		self.is_empty = true
	return Letter.new()
