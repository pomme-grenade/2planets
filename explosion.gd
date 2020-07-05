extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect('animation_finished', self, 'on_animation_finished', [], CONNECT_ONESHOT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt):
	pass

func on_animation_finished():
	queue_free()
