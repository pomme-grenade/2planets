extends Node

static func with_default(nullable, default):
	if nullable != null:
		return nullable
	else:
		return default

static func log(message):
	if ProjectSettings.get_setting("logging/file_logging/enable_file_logging") and OS.is_debug_build():
		var dt=OS.get_datetime()
		print("%02d:%02d:%02d " % [dt.hour,dt.minute,dt.second], str(message))
