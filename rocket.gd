extends Node2D

var target
var velocity

func _ready():
	target = $'../planet1'
	rotation_degrees = 180
	velocity = Vector2(3, 0).rotated(rotation)

func _draw():
	draw_rect(Rect2(Vector2(0, 0), Vector2(15, 5)), Color(0, 0, 255))

func _process(delta):
	velocity += velocity.rotated(position.angle_to(target.position) * 0.01)
	position += velocity * delta
	rotation = velocity.angle()
