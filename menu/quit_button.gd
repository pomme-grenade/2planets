extends Button


func _ready():
	yield(self, 'pressed')
	get_tree().quit()
