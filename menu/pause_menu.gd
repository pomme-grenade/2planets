extends Control

var current_label 

func _ready():
	$Label1.set("custom_colors/font_color", Color(1, 1, 0))
	current_label = $Label1

func _unhandled_input(event):
	if event.is_action_pressed("player2_deconstruct") \
			or event.is_action_pressed("player1_deconstruct"):
		$Label1.set("custom_colors/font_color", Color(1, 1, 1))
		$Label2.set("custom_colors/font_color", Color(1, 1, 0))
		current_label = $Label2
	if event.is_action_pressed("player2_build_income") \
			or event.is_action_pressed("player1_build_income"):
		$Label2.set("custom_colors/font_color", Color(1, 1, 1))
		$Label1.set("custom_colors/font_color", Color(1, 1, 0))
		current_label = $Label1 
	if event.is_action_pressed('pause'):
		get_tree().set_input_as_handled()
		get_tree().paused = false
		queue_free()
	if event.is_action_pressed("ui_accept"):
		if current_label ==  $Label1:
			queue_free()
			GameManager.restart_game()
		elif current_label == $Label2:
			get_tree().quit()
