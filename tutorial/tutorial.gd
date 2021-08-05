extends VBoxContainer

var current_index := 1
var step_amount := 10

func _ready():
	$'Buttons/next'.connect('pressed', self, '_on_next')
	$'Buttons/previous'.connect('pressed', self, '_on_previous')


func _on_previous():
	var current_step := get_node('steps/%d' % current_index)
	current_step.visible = false

	if current_index > 1:
		get_node('steps/%d' % (current_index - 1)).visible = false

func _on_next():
	var current_step := get_node('steps/%d' % current_index)
	current_step.visible = false

	if current_index < step_amount:
		get_node('steps/%d' % (current_index + 1)).visible = false
