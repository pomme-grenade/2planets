extends Sprite

var planet
var player_number
var attack_range = 80
var fire_position
var cooldown = 0
var cooldown_time = 0.5
var health
var type = 'defense'
var is_targeted = false
var targeted_by = null
var is_destroyed = false

signal damage

func _ready():
	call_deferred('init')

func init():
	add_to_group('building' + str(player_number))
	health = 1
	connect('damage', self, 'on_damage')

func _draw():
	draw_texture(preload("building.gd").textures['defense'], Vector2(-4, -4))
	draw_circle(Vector2(0, 0), attack_range, Color(0.1, 0.2, 0.7, 0.1))

	if fire_position != null:
		var alpha = cooldown + 1 - cooldown_time
		if alpha > 0:
			draw_line(Vector2(4, 0).rotated(fire_position.angle()), fire_position, Color(0.9, 0.9, 1, alpha))
		else:
			fire_position = null

func _process(dt):
	if fire_position != null:
		update()

	cooldown -= dt

	if cooldown > 0:
		return

	var enemy_group = 'rocket' + str(1 if player_number == 2 else 2)
	for rocket in get_tree().get_nodes_in_group(enemy_group):
		if global_position.distance_to(rocket.global_position) < attack_range:
			fire_position = to_local(rocket.global_position)
			cooldown = cooldown_time
			rocket.queue_free()
			planet.money += 5
			break

func on_damage():
	health -= 1
	if health < 1:
		queue_free()
