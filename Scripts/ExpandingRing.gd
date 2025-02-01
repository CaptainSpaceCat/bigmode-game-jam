extends Sprite2D

@export var rotation_speed: float = deg_to_rad(90) # Rotation speed in radians per second.
@export var expansion_factor: float = 1 # Exponential factor at which the ring expands (Xmult per second).
@export var max_scale: float = 50.0 # Maximum scale before the ring is removed.


func _process(delta: float) -> void:
	# Rotate the ring around its center.
	rotation += rotation_speed * delta
	
	# Expand the ring.
	scale *= 1 + expansion_factor * delta
	
	# Remove the ring once it expands past the maximum scale.
	if scale.x >= max_scale:
		queue_free()
