extends Control

const SERVER_PORT = 10200
var other_player_id 
var players_done = []

func _ready():
	$create.connect('pressed', self, '_on_create')
	$'VBoxContainer/connect'.connect('pressed', self, '_on_connect')
	get_tree().connect("network_peer_connected", self, "_player_connected")


func _on_connect():
	$create.disabled = true
	var ip = $'VBoxContainer/ip_address'.text
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, SERVER_PORT)
	get_tree().set_network_peer(peer)

func _on_create():
	$'VBoxContainer/connect'.disabled = true
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, 2)
	get_tree().set_network_peer(peer)

remotesync func pre_configure_game():
	var selfPeerID = get_tree().get_network_unique_id()

	var world = load('res://Main.tscn').instance()
	get_node("/root").add_child(world)

	var planet_name = 'planet0' if get_tree().is_network_server() else 'planet1'
	var my_player = get_node('/root/main/' + planet_name)
	my_player.set_name(str(selfPeerID))
	my_player.set_network_master(selfPeerID) # Will be explained later

	var other_planet_name = 'planet1' if get_tree().is_network_server() else 'planet0'	
	var other_player = get_node('/root/main/' + planet_name)
	other_player.set_name(str(other_player_id))
	other_player.set_network_master(other_player_id) # Will be explained later

	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	rpc_id(1, "done_preconfiguring", selfPeerID)
	print("before pause")
	get_tree().set_pause(true)

func _player_connected(id):
	other_player_id = id
	if get_tree().is_network_server():
		rpc(pre_configure_game())

remote func done_preconfiguring(who):
	# Here are some checks you can do, for example
	assert(get_tree().is_network_server())
	assert(not who in players_done) # Was not added yet

	players_done.append(who)

	if players_done.size() == 2:
		rpc("post_configure_game")

remote func post_configure_game():
	get_tree().set_pause(false)
	# Game starts now!
