extends Sprite

export var planetRadius = 110
export (int) var playerNumber
export (Color) var color
export var health = 100

var player
var income = 4
var start_money = 160
var money = 0
var life_label
var current_money_label
var income_label
# warning-ignore:unused_class_variable
# warning-ignore:unused_class_variable
var slot_count = 20
var slot_width
# var label_color = Color("#42286c")
var label_color = Color(0.5, 0.2, 0.2)
var income_label_color = Color(0.8, 0.9, 0.8)

func _ready():
	money += start_money
	life_label = Label.new()
	life_label.align = Label.ALIGN_RIGHT
	get_node("/root/main").call_deferred("add_child", life_label)
	life_label.rect_position = Vector2(position.x - 20, position.y - 20)
	life_label.self_modulate = label_color
	#423458

	current_money_label = preload('res://planet_ui/current_money_label.tscn').instance()
	current_money_label.align = Label.ALIGN_RIGHT
	current_money_label.rect_position = Vector2(position.x - 12, position.y - 5)
	# current_money_label.self_modulate = Color("322742")
	get_node("/root/main").call_deferred("add_child", current_money_label)

	income_label = Label.new()
	income_label.align = Label.ALIGN_RIGHT
	income_label.rect_position = Vector2(position.x - 20, position.y + 10)
	income_label.self_modulate = income_label_color
	get_node("/root/main").call_deferred("add_child", income_label)

	player = preload('res://player/Player.tscn').instance()
	add_child(player)
	player.planet = self
	player.position.y -= planetRadius
	player.playerNumber = playerNumber
	player.name = '%s_player' % name
	# player.modulate = color.lightened(0.5)
	add_to_group('planet')
	slot_width = planetRadius * PI / slot_count

func _draw():
	# draw_circle(Vector2(0, 0), planetRadius, color)
	# draw_rect(Rect2(Vector2(10, 10), Vector2(health, 10)), Color(255, 40, 80))
	var arc_rotation = current_slot_position().direction_to(Vector2(0, 0)).angle() - PI/2
	if (not is_instance_valid(player.current_building)):
		# draw_circle(current_slot_position(), slot_width / 2, Color(1, 1, 1, 0.2))
		draw_circle_arc(Vector2(0, 0), 95, (arc_rotation * 180/PI) - 4, (arc_rotation * 180/PI) + 4, Color(0.3, 0.8, 1, 0.5))

func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 17
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, 1.5)

func _process(delta):
	money += income * delta
	if playerNumber == 1:
		rotation_degrees -= 5 * delta
	elif playerNumber == 2:
		rotation_degrees += 5 * delta

	if is_network_master():
		rpc('_sync_rotation', rotation)

	life_label.text = "%s ♥" % health
	current_money_label.text = "%0.0f$" % money
	income_label.text = "+%0.1f$/s" % income

puppet func _sync_rotation(rot):
	rotation = rot

func current_slot_position():
	var slot_angle_width = PI / slot_count
	var player_position_angle = (player.position.angle() + PI/2)
	var slot_index = round(player_position_angle / slot_angle_width)
	var offset = 0.9
	return Vector2(0, -planetRadius * offset) \
		.rotated(slot_index * slot_angle_width)
