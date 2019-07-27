extends Node2D

var target
var velocity
var rotation_speed = 0.7

func _ready():
	target = $'../building'
	velocity = Vector2(60, 0).rotated(rotation)

func _draw():
	draw_rect(Rect2(Vector2(0, 0), Vector2(4, 1)), Color(0, 50, 255))

func _process(delta):
	if is_instance_valid(target):
	  var target_angle = position.direction_to(target.position)
	  var angle_diff = velocity.angle_to(target_angle)
	  var rotation_direction = sign(angle_diff)
	  velocity = velocity.rotated(rotation_direction * rotation_speed * delta)

	  var acceleration = clamp(1 - abs(angle_diff), 0.1, 0.6) * delta
	  velocity = velocity * (1 + acceleration)

	  if position.distance_to(target.position) < 10:
		  queue_free()
		  target.emit_signal('damage')
		  return

	position += velocity * delta
	rotation = velocity.angle()

