extends Node2D

var planet
var activate_cost = 10
var building_info
var target_player_number
var instant_defense_pulse
var pulse_index = 0 

func init():
	building_info = ''

remotesync func on_activate():
	instant_defense_pulse = preload('res://instant_defense/pulse.tscn').instance()
	instant_defense_pulse.name = '%s_pulse_%d' % [name, pulse_index]
	pulse_index += 1
	instant_defense_pulse.planet = planet
	add_child(instant_defense_pulse)

