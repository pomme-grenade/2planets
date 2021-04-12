extends CheckBox
var config


func _ready():
	config = ConfigFile.new()
	var err = config.load('user://settings.cfg')
	if err != OK and err != ERR_FILE_NOT_FOUND:
		Helper.log(['could not load settings file! ', err])
	var sound_enabled = config.get_value('sound', 'enabled', true)
	self.pressed = sound_enabled

func _toggled(active: bool) -> void:
	AudioServer.set_bus_mute(0, not active)
	config.set_value('sound', 'enabled', active)
	config.save('user://settings.cfg')


