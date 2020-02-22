extends AnimatedSprite

export var player_color = Color(1, 1, 1)

var playerNumber
var movementDirection = 0
var planet
var current_building
var player_key
var ui

var building_cost = {
	attack = 40,
	defense = 40,
	income = 40,
}

export var speed = 1

func _ready():
	set_process_unhandled_input(false)
	call_deferred("init")

func init():
	player_key = "player" + str(playerNumber) + "_"
	set_process_unhandled_input(true)

	spawn_menu()

func _process(delta):
	var rightAction = player_key + "right"
	var leftAction = player_key + "left"

	if Input.is_action_pressed(rightAction):
		flip_h = true
		play("move")
		movementDirection = 1
		planet.update()
	elif Input.is_action_pressed(leftAction):
		flip_h = false
		play("move")
		movementDirection = -1
		planet.update()
	else:
		movementDirection = 0
		stop()

	position = position.rotated(movementDirection * speed  * delta)
	rotation += movementDirection * speed * delta

	var new_building = get_building_in_range()
	if new_building != current_building:
		ui.update()
		current_building = new_building

func _unhandled_input(event):
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
				building.fire_rocket()

func get_building_in_range():
	for building in get_tree().get_nodes_in_group('building' + str(planet.playerNumber)):
		if abs(position.angle_to(building.position)) < (PI / planet.slot_count) / 2:
			return building


func can_build(type):
	return (planet.money >= building_cost[type]
		and not is_instance_valid(current_building))


func spawn_building(type):
	if not can_build(type):
		planet.current_money_label.flash()
		return
	var building = preload("res://building/building.gd").new()
	building.planet = planet
	building.position = planet.current_slot_position()
	building.type = type
	planet.add_child(building)
	# re-draw circle highlighting the new building
	building.init()
	current_building = building
	ui.update()
	planet.update()

	planet.money -=  building_cost[type]

func spawn_menu():
    ui = preload("res://planet_ui/add_building_ui.gd").new()
    get_node("/root/Node2D").call_deferred("add_child", ui)
    ui.rect_position = planet.position + Vector2(-15, -40)
    ui.player = self

func destroy_building(building):
	planet.money += building_cost[current_building.type] / 4
	current_building.is_destroyed = true
	current_building.queue_free()
	ui.update()
	planet.update()
