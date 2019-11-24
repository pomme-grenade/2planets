extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var winner = sceneSwitcher.get_param("winner")
	if winner == 1:
		text = "Left player wins!"
	else:
		text = "Right player wins!"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
