extends Node

var index := 0
var asteroid_spawn_timer
var initial_spawn_time = 30
var asteroid_scene = preload('res://asteroid/asteroid.tscn')

func _ready():
	if is_network_master():
		asteroid_spawn_timer = Timer.new()
		asteroid_spawn_timer.connect('timeout', self, 'spawn_asteroid_rpc')
		add_child(asteroid_spawn_timer)
		asteroid_spawn_timer.start(initial_spawn_time)

func spawn_asteroid_rpc():
	randomize()
	var random_y = [-150, 550][randi() % 2]
	var random_x = rand_range(0, 800)
	var random_position = Vector2(random_x, random_y)
	var random_scale = rand_range(0.5, 1)
	var random_rotation = rand_range(0, PI/4)
	rpc('spawn_asteroid', random_position, random_scale, random_rotation)
	asteroid_spawn_timer.wait_time = rand_range(3, 30)

remotesync func spawn_asteroid(position: Vector2, random_scale, random_rotation):
	var asteroid = asteroid_scene.instance()
	asteroid.name = 'asteroid_%d' % index
	$'/root/main'.add_child(asteroid)
	asteroid.global_position = Vector2(
		position.x,
		position.y
	)
	asteroid.velocity = Vector2(0, 20).rotated(random_rotation)
	if position.y > 0:
		asteroid.velocity = asteroid.velocity.rotated(PI)
	asteroid.scale = Vector2(random_scale, random_scale)
	index += 1