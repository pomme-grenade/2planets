extends Node

static func with_default(nullable, default):
	if nullable != null:
		return nullable
	else:
		return default
