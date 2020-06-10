extends Node2D

var planet

var additional_income = 0.5

func init():
	pass

func on_destroy():
	planet.income -= additional_income

func upgrade():
	return 'res://building/types/drone_upgrade.gd'

func buildup_finish():
	planet.income += additional_income
