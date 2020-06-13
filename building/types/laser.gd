extends Node2D
var planet
var upgrade_1_type = 'laser'
var upgrade_1_script = 'res://building/types/' + upgrade_1_type + '.gd'
var enemy_player_number
var target_planet
var buildings
var toggle_shooting_timer
var shooting = false


func init():
	toggle_shooting_timer = Timer.new()
	toggle_shooting_timer.connect('timeout', self, 'toggle_shooting')
	add_child(toggle_shooting_timer)
	toggle_shooting_timer.start(0.2)
	shooting = true
	enemy_player_number = 1 if planet.playerNumber == 2 else 2
	target_planet = get_node('/root/main/planet_%s' % enemy_player_number)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	buildings = get_tree().get_nodes_in_group('building' + str(enemy_player_number))
	if shooting:
		for building in buildings:
			building.queue_free()
			
	update()

func _draw():
	if shooting:
		draw_line(Vector2(0, 0), Vector2(0, Vector2(0, 0).distance_to(to_local(target_planet.global_position))).rotated(rotation + PI), Color(1, 1, 1), 4)

func toggle_shooting():
	shooting = !shooting
	toggle_shooting_timer.paused = true
