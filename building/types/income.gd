extends AnimatedSprite

var planet
var incomeTimer
var is_destroyed
var type

func init():
	incomeTimer = Timer.new()
	incomeTimer.connect('timeout', self, 'add_income')
	add_child(incomeTimer)
	incomeTimer.start(4)

func add_income():
	show_income_animation("0.06/s")
	planet.income += 0.06

func show_income_animation(text):
	var income_animation = preload('res://Income_animation.tscn').instance()
	income_animation.position = Vector2(-10, 8)
	add_child(income_animation)
	income_animation.label.text = text

remotesync func destroy(cost):
	planet.money += cost / 4
	is_destroyed = true
	queue_free()
	planet.update()
