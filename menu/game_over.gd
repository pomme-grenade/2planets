extends Control

signal unpause

var loser: int
var my_player_number: int

var lobby = preload('res://menu/Lobby.tscn').instance()

func _ready() -> void:
	$'VBoxContainer/menu'.connect('pressed', self, '_on_menu')
	$'VBoxContainer/quit'.connect('pressed', self, '_on_quit')

	if len(get_tree().get_network_connected_peers()) > 0:
		if loser == my_player_number:
			$'Label'.text = 'You Lose'
		else:
			$'Label'.text = 'You Win'

	else:
		if loser == 2:
			$'Label'.text = 'left player wins'
		else:
			$'Label'.text = 'right player wins'

func _on_menu() -> void:
	get_tree().get_root().add_child(lobby)
	get_node('/root/main').queue_free()
	queue_free()

func _on_quit() -> void:
	get_tree().quit()
