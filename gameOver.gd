extends Label

func _ready():
	get_tree().paused = true
	var loser = sceneSwitcher.get_param("loser")
	if loser == 1:
		text = "Right player wins!"
	else:
		text = "Left player wins!"

func _unhandled_input(event):
	if event.is_action_pressed("enter"):
		get_tree().paused = false
		sceneSwitcher.change_scene('res://Main.tscn')
