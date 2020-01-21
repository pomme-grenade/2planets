extends Label

func flash():
	$AnimationPlayer.stop(true)
	$AnimationPlayer.play('flash')

