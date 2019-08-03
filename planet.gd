extends Node2D

export var planetRadius = 100
export (int) var playerNumber
export var color = Color(0, 255, 0)
export var health = 1000

var player
var angle = 0
export var income = 0
var money = 0
var income_label1
var income_label2
var label 

func _ready():
	# income_label1 = get_node("/root/Node2D/Label")
	label = Label.new()
	get_node("/root/Node2D").call_deferred("add_child", label)

	# income_label2 = get_node("/root/Node2D/Label2")
	player = preload("res://player.gd").new()
	player.planet = self
	add_child(player)
	player.position.y -= planetRadius
	player.playerNumber = playerNumber
	# get_node("/root/Node2D").add_child("")
	
	add_to_group('planet')

func _draw():
	draw_circle(Vector2(0, 0), planetRadius, color)

func _process(delta):
	money += income * delta
	rotation_degrees += 0.08
	label.rect_position = Vector2(position.x - label.rect_size.x / 2, position.y - label.rect_size.y / 2)
	label.text = str(int(money))
