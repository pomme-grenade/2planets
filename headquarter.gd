extends Node2D

export (int) var playerNumber
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	draw_rect(Rect2(0, -25, 50, 50), Color(1, 0, 0))

