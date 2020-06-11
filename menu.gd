extends Control

var current_label 

func _ready():
	$Label1.set("custom_colors/font_color", Color(1, 1, 0))

func _unhandled_input(event):
	if event.is_action_pressed("player2_fire_rocket"):
		$Label1.set("custom_colors/font_color", Color(1, 1, 1))
		$Label2.set("custom_colors/font_color", Color(1, 1, 0))
		current_label = $Label2
	if event.is_action_pressed("player2_build_income"):
		$Label2.set("custom_colors/font_color", Color(1, 1, 1))
		$Label1.set("custom_colors/font_color", Color(1, 1, 0))
		current_label = $Label1 
	if event.is_action_pressed('pause'):
		get_tree().set_input_as_handled()
		get_tree().paused = false
		queue_free()
	if event.is_action_pressed("enter"):
		if current_label ==  $Label1:
			get_tree().paused = false
			sceneSwitcher.change_scene('res://Main.tscn')
		if current_label == $Label2:
			get_tree().quit()
