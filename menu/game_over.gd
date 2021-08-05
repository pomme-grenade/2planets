extends Control

var loser: int
var loser_network_id: int
var network_id: int

var lobby = preload('res://menu/Lobby.tscn').instance()

func _ready() -> void:
	$'VBoxContainer/menu'.connect('pressed', self, '_on_menu')
	$'VBoxContainer/quit'.connect('pressed', self, '_on_quit')

	if len(get_tree().get_network_connected_peers()) > 0:
		if loser_network_id == network_id:
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
