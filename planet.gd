extends Node2D

export var planetRadius = 80
export (int) var playerNumber
export (Color) var color
export var health = 100

var player
var income = 3
var start_money = 120
var money = 0
var life_label
var current_money_label
var income_label
# warning-ignore:unused_class_variable
# warning-ignore:unused_class_variable
var slot_count = 20
var slot_width

func _ready():
	money += start_money
	life_label = Label.new()
	life_label.align = Label.ALIGN_RIGHT
	get_node("/root/Node2D").call_deferred("add_child", life_label)
	life_label.rect_position = Vector2(position.x - 20, position.y - 20)

	current_money_label = preload('res://planet_ui/current_money_label.tscn').instance()
	current_money_label.align = Label.ALIGN_RIGHT
	current_money_label.rect_position = Vector2(position.x - 12, position.y - 5)
	get_node("/root/Node2D").call_deferred("add_child", current_money_label)

	income_label = Label.new()
	income_label.align = Label.ALIGN_RIGHT
	income_label.rect_position = Vector2(position.x - 20, position.y + 10)
	get_node("/root/Node2D").call_deferred("add_child", income_label)

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

	life_label.text = "%s ♥" % health
	current_money_label.text = "%0.0f$" % money
	income_label.text = "+%0.1f$" % income


func current_slot_position():
	var slot_angle_width = PI / slot_count
	var slot_index = round(player.rotation / slot_angle_width)
	return Vector2(0, -planetRadius) \
		.rotated(slot_index * slot_angle_width)

