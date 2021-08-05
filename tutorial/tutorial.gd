extends VBoxContainer

var current_index := 1
var step_amount := 6

func _ready():
	$'Buttons/next'.connect('pressed', self, '_on_next')
	$'Buttons/previous'.connect('pressed', self, '_on_previous')


func _on_previous():
	if current_index > 1:
		var current_step := get_node('steps/%d' % current_index)
		current_step.visible = false

		get_node('steps/%d' % (current_index - 1)).visible = true

		current_index -= 1

func _on_next():
	if current_index < step_amount:
		var current_step := get_node('steps/%d' % current_index)
		current_step.visible = false

		get_node('steps/%d' % (current_index + 1)).visible = true

		current_index += 1
