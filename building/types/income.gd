extends Node2D

var planet

var additional_income = 0.5
var upgrade_1_type = 'drone_factory'
var upgrade_1_script = 'res://building/types/' + upgrade_1_type + '.gd'

func init():
	pass

func on_destroy():
	planet.income -= additional_income

func buildup_finish():
	planet.income += additional_income
