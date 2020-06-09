extends Node2D

signal change_type(script_path)
var planet

var additional_income = 0.5

func init():
	pass

func on_destroy():
	planet.income -= additional_income

func upgrade():
	emit_signal('change_type', 'res://building/types/drone_upgrade.gd')

func buildup_finish():
	planet.income += additional_income
