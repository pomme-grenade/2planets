extends Node2D

var planet

const additional_income := 1
var upgrade_1_type = 'repair_drone_factory'
var upgrade_2_type = 'teleporter'
var building_info 

func init():
	building_info = '+ %d $/s' % additional_income
	get_parent().planet.income += additional_income * (get_parent().get_connected_buildings().size() + 1)

func repair_finished():
	get_parent().planet.income += additional_income

func on_destroy():
	get_parent().planet.income -= additional_income

func on_deconstruct():
	get_parent().planet.income -= additional_income
