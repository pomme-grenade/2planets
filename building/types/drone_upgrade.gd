extends Node2D

var planet
var repair_drone

func init():
	new_drone()

func upgrade():
	new_drone()

	# repair_drone.rotation  = repair_drone.position.direction_to(Vector2(0, 0)).angle() - PI/2

func buildup_finish():
	pass

func new_drone():
	repair_drone = preload('res://repair_drone.tscn').instance()
	repair_drone.position = repair_drone.position.rotated(position.direction_to(Vector2(0, 0)).angle() - PI/2)
	repair_drone.position += get_parent().position + Vector2(0, -20)
	repair_drone.z_index = 3 if round(rand_range(1, 3)) == 1 else 1
	planet.add_child(repair_drone)
	repair_drone.init()
	
