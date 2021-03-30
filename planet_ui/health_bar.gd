#warning-ignore-all:return_value_discarded

tool
extends Control

var health = 100
var animated_health = health
var background = 100
var tween: Tween
var tween_target = health
var tween_start_value = health
var width_factor = (rect_size.x - 2) / 100
var timer

const tween_duration = 0.5
const default_tween_delay_duration = 0.5 
const bg_color = Color('#3a3756')
const fg_color = Color('#6a9036')
const dmg_color = Color('#ba5456')
var tween_delay_duration = default_tween_delay_duration

func _ready():
	tween = $'Tween'

	# demo mode for a GIF on reddit
	if Engine.editor_hint:
		timer = Timer.new()
		timer.connect('timeout', self, '_demo_health_change')
		add_child(timer)
		timer.one_shot = true
		timer.start(3)

func _demo_health_change():
	if health <= 0:
		health = 100
	else:
		health = max(health - (10 + (randi() % 10)), 0)
	timer.start(0.1 + randf() * 2)

func _draw():
	draw_line(Vector2(0, 4), Vector2((background * width_factor) + 2, 4), bg_color, 8)
	draw_line(Vector2(1, 4), Vector2(1 + (animated_health * width_factor), 4), dmg_color, 6)
	draw_line(Vector2(1, 4), Vector2(1 + (health * width_factor), 4), fg_color, 6)

func _process(_delta: float):
	# if the player has been healed, reset the animation state to 
	# the current health
	if health > animated_health:
		animated_health = health
		tween_target = health

	$Label.text = ' %d' % health + '%'
	# check if tween was started already, but is still in the delay phase
	var delay_in_effect = tween.is_active() and round(animated_health) == round(tween_start_value)
	var should_animate = health < tween_target
	if should_animate and ((not tween.is_active()) or delay_in_effect):
		start_tween()
		tween_delay_duration = default_tween_delay_duration
	# tween is running, but not in delay - we will wait until it finishes
	# and then instantly start the next tween 
	# so we don't disrupt the tween movement
	elif should_animate and not delay_in_effect:
		tween_delay_duration = 0
		
	update()

func start_tween():
	tween.remove_all()
	tween_start_value = animated_health
	tween_target = health
	tween.interpolate_property(self, 'animated_health',
		animated_health, health, tween_duration,
		Tween.TRANS_QUINT, Tween.EASE_IN, tween_delay_duration)
	tween.start()
