extends Camera2D

# Speed of the camera in pixels per second.
@export var speed: float = 300.0
@export var default_bounds: CollisionShape2D
var bounds_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)

func _ready():
	change_bounds(default_bounds)

func _process(delta: float) -> void:
	var direction := Vector2.ZERO
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	# If there's movement, normalize the direction (so diagonal movement isn't faster)
	if direction != Vector2.ZERO:
		direction = direction.normalized() 
	# Move the camera
	position += direction * speed * delta
	# Clamp the camera's position within the bounds_rect.
	
	var limit_rect: Rect2 = Rect2(bounds_rect)
	#print("Bounds ", limit_rect)
	var camera_rect = self.get_viewport_rect()
	var camera_size = camera_rect.size / self.zoom
	#print("Camera size ", camera_size)
	limit_rect.position += camera_size/2
	limit_rect.size -= camera_size
	#print("Limit ", limit_rect)
	position.x = clamp(position.x, limit_rect.position.x, limit_rect.position.x + limit_rect.size.x)
	position.y = clamp(position.y, limit_rect.position.y, limit_rect.position.y + limit_rect.size.y)


func change_bounds(bounds: CollisionShape2D) -> void:
	var rectangle_shape: RectangleShape2D = bounds.shape
	var rect = Rect2(rectangle_shape.get_rect())
	rect.position += bounds.position
	bounds_rect = rect

# TODO Lock player control and smoothly move camera to goal pos before releasing
func send_to(pos: Vector2):
	pass
	
