extends Node2D

const default_additional_income := 1.0
var additional_income := default_additional_income
# warning-ignore:unused_class_variable
var upgrade_1_type := 'repair_drone_factory'
# warning-ignore:unused_class_variable
# var upgrade_2_type := 'teleporter'
var building_info 
var bonus_per_building := 0.1
var connection_bonus := 0.0
# warning-ignore:unused_class_variable
var activate_cost = 0
var planet

func init():
	get_parent().planet.income += additional_income
	update_income()
	
func update_income():
	get_parent().planet.income -= connection_bonus + additional_income
	if not get_parent().is_destroyed:
		additional_income = default_additional_income
		connection_bonus = get_parent().get_connected_buildings().size() * bonus_per_building
		get_parent().planet.income += connection_bonus + additional_income
	else:
		connection_bonus = 0
		additional_income = 0
	building_info = '+ %.1f $/s\nactivate to teleport' % [additional_income + connection_bonus]

func on_activate():
	if get_parent().is_built and not get_parent().is_destroyed:
		planet.player.position = planet.player.position.rotated(PI)
