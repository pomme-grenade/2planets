extends AnimatedSprite

func _ready():
	connect(
		'animation_finished', 
		self, 
		'on_animation_finished', 
		[], 
		CONNECT_ONESHOT)

func _process(_dt):
	pass

func on_animation_finished():
	queue_free()
