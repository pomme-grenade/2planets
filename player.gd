extends Node2D

var size = Vector2(5, 10)
var playerNumber
var movementDirection = 0
var planet
var money
var current_building
var player_color
var ui_is_open = false
var player_key

export var speed = 1

func _ready():
	set_process_unhandled_input(false)
	call_deferred('init')

func init():
	player_color = planet.color.lightened(0.4)
	player_key = "player" + str(playerNumber) + "_"
	set_process_unhandled_input(true)

func _draw():
	draw_rect(Rect2(Vector2(-size.x / 2, -size.y), size), get_parent().color)

func _process(delta):
	if not ui_is_open:
		var rightAction = player_key + "right"
		var leftAction = player_key + "left"

		if Input.is_action_pressed(rightAction):
			movementDirection = 1
		elif Input.is_action_pressed(leftAction):
			movementDirection = -1
		else:
			movementDirection = 0
	else:
		movementDirection = 0

	position = position.rotated(movementDirection * speed  * delta)
	rotation += movementDirection * speed * delta

	if is_instance_valid(current_building):
		current_building.modulate = player_color
	current_building = get_building_in_range()
	if is_instance_valid(current_building):
		current_building.modulate = player_color.lightened(0.5)

func _unhandled_input(event):
	var can_open_menu = not (is_instance_valid(current_building) or ui_is_open)

	if event.is_action_pressed(player_key + "build") and can_open_menu:
		spawn_menu()

	if event.is_action_pressed("pause"):
		var scene = preload('res://menu.tscn').instance()
		get_node('/root/Node2D').add_child(scene)
		get_tree().paused = true


	if event.is_action_pressed(player_key + "fire_rocket"):
		# var can_fire_rocket = is_instance_valid(current_building) and \
		# 					  current_building.type == 'attack' and \
		# 					  current_building.rocket_amount > 0
		# if can_fire_rocket:

		for building in get_tree().get_nodes_in_group("building" + str(playerNumber)):
			if building.type == 'attack':
				building.fire_all()

func get_building_in_range():
	for building in get_tree().get_nodes_in_group('building' + str(planet.playerNumber)):
		if building.type != 'defense' and position.distance_to(building.position) < 12:
			return building
		elif building.type == 'defense' and position.distance_to(building.position) < 60:
			return building

func spawn_menu():
	var ui = preload("res://add_building_ui.gd").new()
	get_node("/root/Node2D").add_child(ui)
	ui.rect_position = planet.position + Vector2(0, -20)
	ui.player = self
	ui.planet = planet
	ui.connect('close', self, 'ui_was_closed')
	self.ui_is_open = true

func ui_was_closed():
	self.ui_is_open = false
