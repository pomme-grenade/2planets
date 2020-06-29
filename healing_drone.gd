extends Node2D

var destroyed_building
var laser_on
var proximity = 0
var distance_to_planet = 10
var toggle_laser_timer
var attached = false
var current_sin_param = rand_range(0, 10)
var planet

func init():
	toggle_laser_timer = Timer.new()
	toggle_laser_timer.connect('timeout', self, 'toggle_laser')
	add_child(toggle_laser_timer)
	toggle_laser_timer.start(random_laser_timer_countdown())

func _process(dt):
	update()

	if attached:
		planet.health += 0.005

		if planet.health >= 100: 
			detach()

	if attached: 
		current_sin_param += dt
		position = position.rotated(sin(current_sin_param) * (sin(current_sin_param / 2) / 300))
		position *= 1 + (sin(current_sin_param) * 0.002)

	if planet.health < 100: 
		attached = true
		toggle_laser_timer.paused = false

func _draw():
	if (laser_on and attached):
		var swinging_movement = sin(current_sin_param) * 30
		var planet_to_drone_angle = Vector2(0, 0).direction_to(position).angle() - PI / 2
		var global_target = get_parent().to_global(Vector2(swinging_movement, 70).rotated(planet_to_drone_angle))

		draw_line(Vector2(1, 0), (to_local(global_target)), Color(0.5, 0.5, 1, 0.7))

func toggle_laser():
	toggle_laser_timer.wait_time = random_laser_timer_countdown()
	laser_on = !laser_on

func detach():
	laser_on = false
	attached = false
	toggle_laser_timer.paused = true

func random_laser_timer_countdown():
	return rand_range(0.5, 1)
