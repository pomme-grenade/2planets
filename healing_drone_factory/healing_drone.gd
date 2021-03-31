extends Node2D

var destroyed_building
var laser_on
var distance_to_planet = 10
var toggle_laser_timer
var current_sin_param = rand_range(0, 10)
var planet
var active = true setget set_active

func init():
	toggle_laser_timer = Timer.new()
	toggle_laser_timer.connect('timeout', self, 'toggle_laser')
	add_child(toggle_laser_timer)
	toggle_laser_timer.start(random_laser_timer_countdown())
	modulate = Color(0.2, 0.6, 1)

func _process(dt):
	update()

	if not active:
		return

	if planet.health < 100:
		toggle_laser_timer.paused = false
		laser_on = true
		planet.health = min(planet.health + 0.005, 100)
	else:
		detach()

	current_sin_param += dt
	position = position.rotated(sin(current_sin_param) * (sin(current_sin_param / 2) / 300))
	position *= 1 + (sin(current_sin_param) * 0.002)

func _draw():
	if laser_on:
		var swinging_movement = sin(current_sin_param) * 30
		var planet_to_drone_angle = Vector2(0, 0).direction_to(position).angle() - PI / 2
		var global_target = get_parent().to_global(Vector2(swinging_movement, 70).rotated(planet_to_drone_angle))

		draw_line(Vector2(1, 0), (to_local(global_target)), Color(0.5, 0.5, 1, 0.7))

func toggle_laser():
	toggle_laser_timer.wait_time = random_laser_timer_countdown()
	laser_on = !laser_on

func set_active(new_active):
	active = new_active
	if not active:
		detach()
		modulate = Color(1, 0.6, 0.6)
	else:
		modulate = Color(0.2, 0.6, 1)

func detach():
	laser_on = false
	toggle_laser_timer.paused = true

func random_laser_timer_countdown():
	return rand_range(0.5, 1)
