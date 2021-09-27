extends Button

func _ready():
	connect('pressed', self, '_press')

func _press() -> void:
	OS.shell_open('https://discord.gg/6YB4URR3pC')


