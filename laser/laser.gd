extends Node2D

var planet: Sprite
var enemy_player_number
var buildings
var stop_laser_timer
var shooting := false
var can_activate := true
var laser_position := 0
var activate_cost := 20
var laser_range := 300
var one_building_destroyed = false
var building_info
var initial_delay = 1.0
var initial_delay_timer 
var animated_beam = AnimatedTexture.new()
var beam_texture

func init() -> void:
	building_info = ''

	enemy_player_number = 1 if planet.player_number == 2 else 2

	stop_laser_timer = Timer.new()
	stop_laser_timer.one_shot = true
	add_child(stop_laser_timer)

	initial_delay_timer = Timer.new()
	initial_delay_timer.one_shot = true
	add_child(initial_delay_timer)

	animated_beam.set_frames(10)
	animated_beam.set_fps(20.0)
	animated_beam.oneshot = true
	set_frame_images()

func _process(_dt) -> void:
	if shooting:
		buildings = get_tree().get_nodes_in_group('building' + str(enemy_player_number))
		for building in buildings:
			var distance_to_building = Vector2(0, 0).distance_to(to_local(building.global_position))

			if Vector2(0, -distance_to_building).distance_to(to_local(building.global_position)) < 10 \
					and distance_to_building < laser_range and not building.is_destroyed and not one_building_destroyed:
				building.destroy()
				laser_position = distance_to_building
				one_building_destroyed = true
				update()
				return

func _draw() -> void:
	if shooting:
		for n in range (1, laser_position, beam_texture.get_size().y):
			draw_texture(animated_beam, Vector2(-beam_texture.get_size().y / 4, -n - beam_texture.get_size().y))


func on_activate() -> void:
	if can_activate:
		can_activate = false
		get_parent().play('beam_startup')
		initial_delay_timer.start(initial_delay)
		yield(initial_delay_timer, 'timeout')
		start_shooting()
		yield(stop_laser_timer, 'timeout')
		stop_laser()


func stop_laser() -> void:
	laser_position = 0
	shooting = false
	can_activate = true
	one_building_destroyed = false
	update()


func start_shooting() -> void:
	shooting = true
	get_parent().play('laser')
	stop_laser_timer.start(0.5)
	laser_position = laser_range
	animated_beam.current_frame = 0
	update()


func set_frame_images() -> void:
	for n in range (1, 11):
		var png_path = "res://laser/beam%d.png" % n
		beam_texture = load(png_path)
		animated_beam.set_frame_texture(n-1, beam_texture)
