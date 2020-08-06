tool
extends Node2D

var planet
var health = 100
var delayed_health = 100
var background = 100
var tween
var timer_started = false
var tween_timer
var interpolation_started = false
var expected_health_decrease

const interpolation_duration = 0.5

func _ready():
	tween = $'Tween'
	tween_timer = Timer.new()
	tween_timer.connect('timeout', self, 'toggle_tween')
	add_child(tween_timer)

func _draw():
	draw_line(Vector2(0, 0), Vector2(background * 0.62, 0), Color(0, 0, 0), 7)
	draw_line(Vector2(0, 0), Vector2((delayed_health) * 0.62, 0), Color(1, 1, 1), 7)
	draw_line(Vector2(0, 0), Vector2(health * 0.62, 0), Color(0.6, 0.6, 0.9), 7)

func _process(_delta):
	if health < delayed_health and not timer_started:
		tween_timer.start(0.5)
		timer_started = true
		expected_health_decrease = health
	elif timer_started and health < expected_health_decrease:
		tween_timer.stop()
		tween_timer.start(0.5)
		expected_health_decrease = health
		if interpolation_started:
			tween.interpolate_property(self, 'delayed_health',
				delayed_health, health, interpolation_duration,
				Tween.TRANS_QUINT, Tween.EASE_IN)

	update()

func toggle_tween():
	if !interpolation_started:
		tween.interpolate_property(self, 'delayed_health',
			delayed_health, health, interpolation_duration,
			Tween.TRANS_QUINT, Tween.EASE_IN)
		tween.start()
		tween_timer.start(interpolation_duration)
	elif interpolation_started:
		timer_started = false
		
	interpolation_started = !interpolation_started
