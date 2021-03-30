extends Label

onready var tree := get_tree()

func _ready():
	if tree.multiplayer.is_network_server():
		tree.connect('network_peer_disconnected', self, '_disconnected')
	else:
		tree.connect('server_disconnected', self, '_disconnected')

	self.visible = false


func _disconnected(_maybe_peer_id = null):
	self.visible = true
