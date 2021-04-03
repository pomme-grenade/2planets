extends Node2D

var image_texture: ImageTexture
var initial_acceleration := -200.0
var planet: Sprite

var all_textures := []

func _draw() -> void:
	for texture in all_textures:
		draw_texture(image_texture, texture.position, Color(1, 1, 1, texture.alpha))

func _process(dt: float) -> void:
	for texture in all_textures:
		texture.direction = texture.position.direction_to(planet.global_position)
		texture.acceleration += 10.0
		texture.position += texture.direction * texture.acceleration * dt
        texture.alpha -= 0.01
		update()

		if texture.position.distance_to(planet.global_position) < 20.0:
			all_textures.erase(texture)

func create(initial_position: Vector2, planet: Sprite) -> void:
	var direction: Vector2

	self.planet = planet

	image_texture = ImageTexture.new()
	image_texture.load('res://money.png')

	direction = initial_position.direction_to(planet.global_position)

	initial_position.x -= image_texture.get_size().x / 2.0
	initial_position.y -= image_texture.get_size().y / 2.0

	all_textures.append({
		"position": initial_position, 
		"direction": direction,
		"acceleration": initial_acceleration,
		"alpha": 2.0
	})
