extends Control

var current_label 

func _ready():
	$Label.set("custom_colors/font_color", Color(1, 1, 0))

func _process(delta):
	pass

func _unhandled_input(event):
	if event.is_action_pressed("player2_down"):
		$Label.set("custom_colors/font_color", Color(1, 1, 1))
		$Label2.set("custom_colors/font_color", Color(1, 1, 0))
		current_label = $Label2
	if event.is_action_pressed("player2_up"):
		$Label2.set("custom_colors/font_color", Color(1, 1, 1))
		$Label.set("custom_colors/font_color", Color(1, 1, 0))
		current_label = $Label1
	if event.is_action_pressed('menu'):
		get_tree().set_input_as_handled()
		get_tree().paused = false
		queue_free()
	if event.is_action_pressed("enter"):
		if current_label == $Label1:
			get_tree().paused = false
			get_tree().change_scene("res://Main.tscn")
			# get_tree().reload_current_scene()
		if current_label == $Label2:
			get_tree().quit()
