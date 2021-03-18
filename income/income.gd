extends Node2D

var planet

const additional_income := 1.0
var upgrade_1_type = 'repair_drone_factory'
var upgrade_2_type = 'teleporter'
var building_info 
var connection_bonus = 0.0

func init():
	building_info = '+ %d $/s' % additional_income
	connection_bonus = get_parent().get_connected_buildings().size() * (additional_income * 0.2)
	get_parent().planet.income += additional_income + connection_bonus
	
func update_connection_bonus():
	get_parent().planet.income -= connection_bonus
	connection_bonus = get_parent().connected_buildings.size() * (additional_income * 0.2)
	get_parent().planet.income += connection_bonus

func repair_finished():
	get_parent().planet.income += additional_income + connection_bonus

func on_destroy():
	get_parent().planet.income -= additional_income + connection_bonus

func on_deconstruct():
	get_parent().planet.income -= additional_income + connection_bonus
