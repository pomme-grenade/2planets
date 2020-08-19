extends Node2D

var planet

var additional_income = 1
var upgrade_1_type = 'repair_drone_factory'
var upgrade_2_type = 'teleporter'
var building_info 

func init():
	building_info = '+ %d $/s' % additional_income
