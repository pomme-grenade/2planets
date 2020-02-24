extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var label
var newTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	label = get_node("Label")# Replace with function body.
	newTimer = Timer.new()
	# warning-ignore:return_value_discarded
	newTimer.connect('timeout', self, 'do_anim_finished')
	add_child(newTimer)
	newTimer.start(1)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func do_anim_finished():
	queue_free()

