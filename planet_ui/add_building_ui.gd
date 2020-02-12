extends Control

var player

func _draw():
	var gap = 15
	var textures = preload('res://building/building.gd').textures
	var delete = preload('res://planet_ui/delete_icon.png')


	if is_instance_valid(player.current_building):
		draw_rect(Rect2(Vector2(-3, 0), Vector2(10, 10)), Color(1, 1, 1))
		draw_texture(delete, Vector2(gap - 3, 0))
		# draw_rect(Rect2(Vector2(gap - 3, 0), Vector2(10, 10)), Color(0, 0, 0))
		draw_rect(Rect2(Vector2(2 * gap - 3, 0), Vector2(10, 10)), Color(1, 1, 1))
	else:
		var types = ['defense', 'income', 'attack']
		# rotate all icons by 90 degrees
		draw_set_transform(Vector2(0, 0), PI/2, Vector2(1, 1))
		for index in range(len(types)):
			draw_texture(textures[types[index]], Vector2(0, -gap * index - 5))

