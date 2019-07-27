extends Node2D

export var planetRadius = 100
export (int) var playerNumber
export var color = Color(0, 255, 0)

var player

func _ready():
	player = preload("res://player.gd").new()
	add_child(player)
	player.position.y -= planetRadius
	player.playerNumber = playerNumber

func _draw():
	draw_circle(Vector2(0, 0), planetRadius, color)

func _process(delta):
	# player.position = player.position.rotated(0.5 * delta)
	# player.rotation += 0.5 * delta
	pass
