extends Node2D

var planet

var additional_income = 0.5
var upgrade_1_type = 'drone_factory'
var upgrade_2_type = 'teleporter'
var building_info 

func init():
	building_info = '+ 0.5 $/s'

func on_destroy():
	planet.income -= additional_income

func buildup_finish():
	planet.income += additional_income
