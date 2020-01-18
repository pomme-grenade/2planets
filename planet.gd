extends Node2D

export var planetRadius = 100
export (int) var playerNumber
export (Color) var color
export var health = 100

var player
var angle = 0
var income = 0.3
var start_money = 6
var money = 0
var income_label1
var income_label2
var label
var is_targeted
var targeted_by
var slot_count = 20
var slot_width

func _ready():

	is_targeted = false
	money += start_money
	label = Label.new()
	get_node("/root/Node2D").call_deferred("add_child", label)

	player = preload('res://Player.tscn').instance()
	add_child(player)
	player.planet = self
	player.position.y -= planetRadius
	player.playerNumber = playerNumber
	add_to_group('planet')
	slot_width = planetRadius * PI / slot_count


func _draw():
	draw_circle(Vector2(0, 0), planetRadius, color)
	# draw_rect(Rect2(Vector2(10, 10), Vector2(health, 10)), Color(255, 40, 80))
	draw_circle(current_slot_position(), slot_width / 2, Color(1, 1, 1, 0.2))

func _process(delta):
	money += income * delta
	if playerNumber == 1:
		rotation_degrees -= 0.08
	elif playerNumber == 2:
		rotation_degrees += 0.08

	label.rect_position = Vector2(position.x - label.rect_size.x / 2, position.y - label.rect_size.y / 2)
	label.text = "%s ♥\n%0.1f$\n+%0.1f$" % [health, money, income]
	label.align = label.ALIGN_RIGHT


func current_slot_position():
	var slot_angle_width = PI / slot_count
	var slot_index = round(player.rotation / slot_angle_width)
	return Vector2(0, -planetRadius) \
		.rotated(slot_index * slot_angle_width)

