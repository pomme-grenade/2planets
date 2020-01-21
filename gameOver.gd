extends Label

func _ready():
	var loser = sceneSwitcher.get_param("loser")
	if loser == 1:
		text = "Right player wins!"
	else:
		text = "Left player wins!"

func _unhandled_input(event):
	if event.is_action_pressed("enter"):
		sceneSwitcher.change_scene('res://Main.tscn')
