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
	else:
		movementDirection = 0
	if event.is_action_pressed(player_key + "up"):
		movementDirection = 0
		var ui = preload("res://add_building_ui.gd").new()
		planet.add_child(ui)
		ui.player = self
		ui.planet = planet

	if event.is_action_pressed(player_key + "down"):
		for building in get_tree().get_nodes_in_group('building' + str(planet.playerNumber)):
				if building.type == 'attack' and ((position.distance_to(building.position)) < 2) and building.rocket_amount > 0:
					building.fire_rocket()
					building.rocket_amount -= 1
