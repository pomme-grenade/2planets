extends AnimatedSprite

var planet
var is_destroyed = false
var type

var target_player_number

func init():
	pass

func try_fire_rocket(name):
	if planet.money < 10 or (not is_network_master()):
		planet.current_money_label.flash()
		return

	var position = global_position - Vector2(5, 0).rotated(global_rotation)
	rpc('fire_rocket', name, position, global_rotation + PI)

remotesync func fire_rocket(name, position, rotation):
	planet.money -= 10
	show_income_animation("0.05/s")
	planet.income += 0.05
	var rocket = preload("res://rocket.gd").new(target_player_number)
	rocket.name = name
	rocket.position = position
	rocket.rotation = rotation + PI/2
	rocket.from_planet = planet
	rocket.building = self
	rocket.set_network_master(get_network_master())
	$'/root/main'.add_child(rocket)
	update()

remotesync func destroy(cost):
	planet.money += cost / 4
	is_destroyed = true
	queue_free()
	planet.update()

func show_income_animation(text):
	var income_animation = preload('res://Income_animation.tscn').instance()
	income_animation.position = Vector2(-10, 8)
	add_child(income_animation)
	income_animation.label.text = text
