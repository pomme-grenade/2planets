extends Control

var house_bonus_income_lvl1 = 0.1
var current_cost

func _draw():
	var gap = 15
	var item_size = 10

	var textures = preload("building.gd").textures
	var types = ['defense', 'income', 'attack']
	for index in range(len(types)):
		draw_texture(textures[types[index]], Vector2(gap * index - 3, -20))
