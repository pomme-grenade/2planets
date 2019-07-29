extends Node2D

var size = Vector2(5, 10)
var playerNumber
var movementDirection = 0
var planet
var money

export var speed = 1

func _ready():
	pass

func _draw():
	draw_rect(Rect2(Vector2(-size.x / 2, -size.y), size), get_parent().color)

func _process(delta):
	position = position.rotated(movementDirection * speed  * delta)
	rotation += movementDirection * speed * delta

func _unhandled_input(event):
	var player_key = "player" + str(playerNumber) + "_"
	var rightAction = player_key + "right"
	var leftAction = player_key + "left"
	if Input.is_action_pressed(rightAction):
		movementDirection = 1
	elif Input.is_action_pressed(leftAction):
		movementDirection = -1
	elif event.is_action_pressed(player_key + "up"):
		var ui = preload("res://add_building_ui.gd").new()
		planet.add_child(ui)
		ui.player = self
		ui.planet = planet
	else:
		movementDirection = 0
