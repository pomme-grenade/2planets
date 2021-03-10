extends Sprite

export var planetRadius = 110
export (int) var player_number
export (Color) var color
export var health := 100.0 setget set_health

const slot_count = 14
const slot_angle_width = PI / slot_count

var player
var income = 4
var start_money = 200
remotesync var money = 0
var slot_width
var label_color = Color("#42286c")
var health_bar
var current_slot_index setget ,get_current_slot_index


func _ready():
	money += start_money

	rset_config('rotation', MultiplayerAPI.RPC_MODE_PUPPET)

	player = preload('res://player/Player.tscn').instance()
	add_child(player)
	player.planet = self
	player.position.y -= planetRadius
	player.player_number = player_number
	player.name = '%s_player' % name
	player.set_network_master(get_network_master())
	# player.modulate = color.lightened(0.5)
	slot_width = planetRadius * PI / slot_count

	health_bar = get_node('/root/main/planet_ui_%s/health_bar' % player_number)

	add_to_group('planets')

	if is_network_master():
		var timer = Timer.new()
		timer.one_shot = false;
		timer.connect("timeout", self, "sync_rot_and_money")
		timer.wait_time = 5
		timer.autostart = true
		add_child(timer)


func _draw():
	var arc_rotation = \
		current_slot_position() \
		.direction_to(Vector2(0, 0)) \
		.angle() - PI / 2

	draw_circle_arc(
		Vector2(0, 0),
		95,
		(arc_rotation * 180 / PI) - (slot_width / 4),
		(arc_rotation * 180 / PI) + (slot_width / 4),
		Color(0.3, 0.8, 1, 0.5)
	)


func draw_circle_arc(center, radius, angle_from, angle_to, arc_color):
	var nb_points = 17
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(
			angle_from + i * (angle_to - angle_from) / nb_points - 90
		)
		points_arc.push_back(
			center + Vector2(cos(angle_point), 
			sin(angle_point)) * radius
		)

	for index_point in range(nb_points):
		draw_line(
			points_arc[index_point], 
			points_arc[index_point + 1], 
			arc_color, 1.5
		)


func _process(delta):
	health_bar.health = health
	health_bar.get_node('Label').text = ' %d' % health + '%'
	money += income * delta
	if player_number == 1:
		rotation_degrees -= 5 * delta
	elif player_number == 2:
		rotation_degrees += 5 * delta

	update()

func sync_rot_and_money():
	rset_unreliable('rotation', rotation)
	rset_unreliable('money', money)


func get_current_slot_index():
	var player_position_angle = player.position.angle() + PI / 2
	return round(player_position_angle / slot_angle_width)


func current_slot_position():
	var offset = 0.9
	return Vector2(0, - planetRadius * offset) \
		.rotated(self.current_slot_index * slot_angle_width)


func set_health(new_health: float):
	health = new_health

	if health <= 0:
		GameManager.game_over(player_number)
