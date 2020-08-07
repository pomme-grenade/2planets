extends Node2D

var loser

func _ready():
	get_tree().paused = true
	if loser == 1:
		$Label1.text = "Right player wins!"
	else:
		$Label1.text = "Left player wins!"

func _unhandled_input(event):
	if event.is_action_pressed("enter"):
		queue_free()
		GameManager.restart_game()
