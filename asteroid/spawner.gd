extends Node

var index := 0
var asteroid_spawn_timer
var initial_spawn_time = 1
var asteroid_scene = preload('res://asteroid/asteroid.tscn')

func _ready():
	asteroid_spawn_timer = Timer.new()
	asteroid_spawn_timer.connect('timeout', self, 'spawn_asteroid')
	add_child(asteroid_spawn_timer)
	asteroid_spawn_timer.start(initial_spawn_time)
	randomize()

func spawn_asteroid():
	var random_y = [-150, 550][randi() % 2]
	var random_x = rand_range(0, 800)

	var asteroid = asteroid_scene.instance()
	$'/root/main'.add_child(asteroid)
	asteroid.global_position = Vector2(
		random_x,
		random_y
	)
	asteroid.velocity = Vector2(0, 20).rotated(rand_range(0, PI/4))
	if random_y > 0:
		asteroid.velocity = asteroid.velocity.rotated(PI)
	asteroid.name = 'asteroid_%d' % index
	var random_scale = rand_range(0.5, 1)
	asteroid.scale = Vector2(random_scale, random_scale)
	index += 1
	asteroid_spawn_timer.wait_time = rand_range(0.5, 2)
