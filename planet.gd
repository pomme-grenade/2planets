extends Node2D

export var planetRadius = 100
var player
var angle = 0

func _ready():
	player = preload("res://player.gd").new()
	add_child(player)
	player.position.y -= planetRadius

func _draw():
	draw_circle(Vector2(0, 0), planetRadius, Color(0, 255, 0))

func _process(delta):
	# player.position = player.position.rotated(0.5 * delta)
	# player.rotation += 0.5 * delta
	pass
