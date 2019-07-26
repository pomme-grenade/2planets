extends Node2D

var target
var velocity

func _ready():
	target = $'../planet1'
	rotation_degrees = 180
	velocity = Vector2(130, 0).rotated(rotation)

func _draw():
	draw_rect(Rect2(Vector2(0, 0), Vector2(10, 3)), Color(0, 0, 255))

func _process(delta):
	var target_angle = (target.position - position).angle()
	var angle_diff = target_angle - velocity.angle()
	velocity = velocity.rotated(angle_diff * 1 * delta)
	var acceleration = max(0, 1 - angle_diff) * delta
	velocity = velocity * (1 + acceleration)

	position += velocity * delta
	rotation = velocity.angle()
