extends Sprite

export var planetRadius = 110
export (int) var playerNumber
export (Color) var color
export var health = 100

var player
var income = 4
var start_money = 200
var money = 0
var slot_count = 14
var slot_width
var label_color = Color("#42286c")
var health_bar

func _ready():
	money += start_money

	player = preload('res://player/Player.tscn').instance()
	add_child(player)
	player.planet = self
	player.position.y -= planetRadius
	player.playerNumber = playerNumber
	player.name = '%s_player' % name
	# player.modulate = color.lightened(0.5)
	slot_width = planetRadius * PI / slot_count

	health_bar = get_node('/root/main/planet_ui_%s/health_bar' % playerNumber)

	for i in range(3):
		if playerNumber == 1:
			var asteroid_indicator = preload('res://asteroid_indicator.tscn').instance()
			$'/root/main'.call_deferred('add_child', asteroid_indicator)
			asteroid_indicator.position = Vector2(0, 0)

			var asteroid = preload('res://asteroid.tscn').instance()
			$'/root/main'.call_deferred('add_child', asteroid)
			asteroid.position = Vector2(rand_range(-30, 0) + i * 50, rand_range(-50, -80))
			asteroid.name = 'asteroid_%s_%d' % [playerNumber, i]
			var random_scale = rand_range(0.5, 1)
			asteroid.scale = Vector2(random_scale, random_scale)

func _draw():
	var arc_rotation = current_slot_position().direction_to(Vector2(0, 0)).angle() - PI/2
	if (not is_instance_valid(player.current_building)):
		draw_circle_arc(Vector2(0, 0), 95, (arc_rotation * 180/PI) - (slot_width / 4), (arc_rotation * 180/PI) + (slot_width / 4), Color(0.3, 0.8, 1, 0.5))

func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 17
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, 1.5)

func _process(delta):
	health_bar.health = health
	health_bar.get_node('Label').text = ' %d' % health + '%' 
	money += income * delta
	if playerNumber == 1:
		rotation_degrees -= 5 * delta
	elif playerNumber == 2:
		rotation_degrees += 5 * delta

	if is_network_master():
		rpc('_sync_rotation', rotation)

puppet func _sync_rotation(rot):
	rotation = rot

func current_slot_position():
	var slot_angle_width = PI / slot_count
	var player_position_angle = (player.position.angle() + PI/2)
	var slot_index = round(player_position_angle / slot_angle_width)
	var offset = 0.9
	return Vector2(0, -planetRadius * offset) \
		.rotated(slot_index * slot_angle_width)
