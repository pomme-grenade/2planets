extends Node2D

var planet

var additional_income = 0.5

func init():
	planet.income += additional_income

func on_destroy():
	planet.income -= additional_income

func upgrade():
	pass
