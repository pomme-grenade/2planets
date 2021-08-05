extends Node2D

var image_texture: ImageTexture
var initial_acceleration := -50.0
var planet: Sprite
var money_texture: Texture = preload('res://money.png')
var time_since_last_rocket = 0.0

var all_textures := []

func _draw() -> void:
	for texture in all_textures:
		draw_rect(Rect2(texture.position, Vector2(1, 1)), Color(0.5, 1.0, 0.5, texture.alpha))

func _process(dt: float) -> void:

	for texture in all_textures:
		move_down(texture, dt)

		if texture.position.distance_to(planet.global_position) < 20.0:
			all_textures.erase(texture)
			get_node('/root/main/planet_ui_%d/current_money_label/money/AnimationPlayer' % planet.player_number).play('flash')


		update()

func move_down(texture, dt) -> void:
	texture.direction = texture.position.direction_to(planet.global_position)
	texture.acceleration += 20.0
	texture.position += texture.direction * texture.acceleration * dt
	texture.alpha -= 0.01

func create(initial_position: Vector2, for_planet: Sprite) -> void:
	var direction: Vector2

	self.planet = for_planet

	var image: Image = money_texture.get_data()

	image_texture = ImageTexture.new()
	image_texture.create_from_image(image)

	direction = initial_position.direction_to(for_planet.global_position)

	initial_position.x -= image_texture.get_size().x / 2.0
	initial_position.y -= image_texture.get_size().y / 2.0

	all_textures.append({
		"position": initial_position, 
		"direction": direction,
		"acceleration": initial_acceleration,
		"alpha": 1.5,
	})

	time_since_last_rocket = 0.0
