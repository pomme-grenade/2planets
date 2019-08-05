extends Node2D

var size = Vector2(5, 10)
var playerNumber
var movementDirection = 0
var planet
var money
var rocketGroup
var current_building
var player_color 
var ui

export var speed = 1

func _ready():
	call_deferred('init')

func init():
	player_color = planet.color.lightened(0.25)

func _draw():
	draw_rect(Rect2(Vector2(-size.x / 2, -size.y), size), get_parent().color)

func _process(delta):
	position = position.rotated(movementDirection * speed  * delta)
	rotation += movementDirection * speed * delta
	if is_instance_valid(current_building):
		current_building.modulate = player_color
	current_building = get_building_in_range()
	if is_instance_valid(current_building):
		current_building.modulate = player_color.lightened(0.5)

func _unhandled_input(event):
	var player_key = "player" + str(playerNumber) + "_"
	var rightAction = player_key + "right"
	var leftAction = player_key + "left"
	var rocketGroup = get_tree().get_nodes_in_group("rocket" + str(playerNumber))
	if not is_instance_valid(ui):
		if Input.is_action_pressed(rightAction):
			movementDirection = 1
		elif Input.is_action_pressed(leftAction):
			movementDirection = -1
		else:
			movementDirection = 0
	else:
		movementDirection = 0

	if event.is_action_pressed(player_key + "up"):
		if  is_instance_valid(current_building):
			return

		ui = preload("res://add_building_ui.gd").new()
		get_node("/root/Node2D").add_child(ui)
		ui.rect_position = planet.position
		ui.player = self
		ui.planet = planet

	if event.is_action_pressed(player_key + "down"):
		if current_building != null and current_building.type == 'attack' and current_building.rocket_amount > 0:
			# rocketGroup[rocketGroup.size() - 1].ready = true
			# rocketGroup[rocketGroup.size() - 1].rocket_amount -= 1
			current_building.fire_rocket()

func get_building_in_range():
	for building in get_tree().get_nodes_in_group('building' + str(planet.playerNumber)):
		if position.distance_to(building.position) < 12:
			return building
