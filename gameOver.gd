extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var loser = sceneSwitcher.get_param("loser")
	if loser == 1:
		text = "Right player wins!"
	else:
		text = "Left player wins!"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
