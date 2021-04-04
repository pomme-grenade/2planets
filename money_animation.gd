extends Node2D

var image_texture: ImageTexture
var initial_acceleration := -200.0
var planet: Sprite
var money_texture: Texture = preload('res://money.png')
var time_since_last_rocket = 0.0

var all_textures := []

func _draw() -> void:
	for texture in all_textures:
		draw_texture(image_texture, texture.position, Color(1, 1, 1, texture.alpha))

func _process(dt: float) -> void:
	time_since_last_rocket += dt

	for texture in all_textures:
		if texture.move_up:
			move_up(texture, dt)
		elif time_since_last_rocket > 2.0 or texture.already_started:
			texture.already_started = true
			move_down(texture, dt)
		else:
			stop_motion(texture)

		if texture.position.distance_to(planet.global_position) < 20.0:
			all_textures.erase(texture)

		update()

func move_up(texture, dt) -> void:
	texture.direction = texture.position.direction_to(planet.global_position)
	texture.acceleration += 5.0
	texture.position += texture.direction * texture.acceleration * dt
	texture.alpha -= 0.01

func stop_motion(texture) -> void:
	texture.acceleration = 0.0
	texture.alpha -= 0.001

func move_down(texture, dt) -> void:
	texture.direction = texture.position.direction_to(planet.global_position)
	texture.acceleration += 10.0
	texture.position += texture.direction * texture.acceleration * dt
	texture.alpha -= 0.01

func start_timers(texture) -> void:
	texture.move_up = true
	yield(get_tree().create_timer(0.6), 'timeout')
	texture.move_up = false

func create(initial_position: Vector2, planet: Sprite) -> void:
	var direction: Vector2

	self.planet = planet

	var image: Image = money_texture.get_data()

	image_texture = ImageTexture.new()
	image_texture.create_from_image(image)

	direction = initial_position.direction_to(planet.global_position)

	initial_position.x -= image_texture.get_size().x / 2.0
	initial_position.y -= image_texture.get_size().y / 2.0

	all_textures.append({
		"position": initial_position, 
		"direction": direction,
		"acceleration": initial_acceleration,
		"alpha": 1.5,
		"move_up": false,
		"move_down": false,
		"already_started": false
	})

	time_since_last_rocket = 0.0

	start_timers(all_textures[all_textures.size() - 1])
