extends Node2D

var planet
var activate_cost = 10
var building_info
var target_player_number
var instant_defense_pulse
var pulse_index = 0 

func init():
	building_info = ''

	get_parent().position /= 1.5
	get_parent().rotation = get_parent().position.direction_to(Vector2(0, 0)).angle() - PI / 2

func on_activate():
	instant_defense_pulse = preload('res://instant_defense_pulse.tscn').instance()
	instant_defense_pulse.name = '%s_pulse_%d' % [name, pulse_index]
	pulse_index += 1
	instant_defense_pulse.planet = planet
	add_child(instant_defense_pulse)

