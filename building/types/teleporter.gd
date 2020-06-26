extends Node2D
var planet

func on_activate():
	if get_parent().is_built and not get_parent().is_destroyed:
		planet.player.position = planet.player.position.rotated(PI)
