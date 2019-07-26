extends Node2D

var size = Vector2(10, 20)
var playerNumber

export var speed = 1


func _ready():
	pass
	
func _draw():
	draw_rect(Rect2(Vector2(-size.x / 2, -size.y), size), Color(255, 0, 0)) 
	
func _process(delta):
	var direction = 0
	if Input.is_action_pressed("player" + str(playerNumber) + "_right"):
		direction = 1
	elif Input.is_action_pressed("player" + str(playerNumber) + "_left"):
		direction = -1

	position = position.rotated(direction * speed  * delta)
	rotation += direction * speed * delta



