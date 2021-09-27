extends Node

var other_player_id
var players_done = []
var hole_puncher
var game_code
const traversal_server_ip := '88.198.207.9'
const traversal_server_port := 13000

signal exit_lobby
signal update_status(text)

func _ready():	
	# warning-ignore:return_value_discarded
	get_tree().connect('network_peer_connected', self, '_player_connected')

func server_for_local_game(tutorial: bool):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(GameManager.SERVER_PORT, 2)
	get_tree().set_network_peer(peer)
	var world = load('res://Main.tscn').instance()
	get_node('/root').add_child(world)

	if !tutorial:
		world.get_node('tutorial').queue_free()
	else:
		world.get_node('planet_1').position.y -= 50
		world.get_node('planet_2').position.y -= 50
		world.get_node('planet_ui_1').set_margin(MARGIN_TOP, -100)
		world.get_node('planet_ui_2').set_margin(MARGIN_TOP, -100)
	var selfPeerID = get_tree().get_network_unique_id()
	get_node('/root').set_network_master(selfPeerID)

	emit_signal('exit_lobby')


func connect_to_server(code):
	game_code = code
	Helper.log('traversing nat...')
	var result = yield(traverse_nat(false), 'completed')
	Helper.log('nat traversed!')
	var host_address = result[2]
	var host_port = result[1]
	var own_port = result[0]
	Helper.log(['own port ', own_port])
	Helper.log(['host: ', host_address, ':', host_port])

	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(host_address, host_port, 0, 0, own_port)
	get_tree().set_network_peer(peer)


func start_server():
	Helper.log('traversing nat...')
	game_code = generate_game_code()
	var result = yield(traverse_nat(true), 'completed')
	Helper.log('nat traversed!')
	var my_port = result[0]
	Helper.log(['my port ', my_port])

	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(my_port, 1)
	if (err != OK):
		Helper.log(['could not create server: ', err])
		emit_signal('update_status', 'Failed to create game server')
	get_tree().set_network_peer(peer)

func reset():
	var tree = get_tree()
	if hole_puncher != null:
		if hole_puncher.is_host:
			hole_puncher.finalize_peers(game_code)
		# we shouldn't have to call this as the server normally
		# does this when we call finalize_peers,
		# but if our client is still registered in an old, lingering 
		# session, it won't get cleaned up without the following call
		hole_puncher.checkout()
		hole_puncher.queue_free()

	if tree.network_peer == null:
		return

	tree.network_peer.close_connection()
	tree.network_peer = null


func _player_connected(id):
	get_tree().refuse_new_network_connections = true
	other_player_id = id
	if get_tree().is_network_server():
		rpc('pre_configure_game')


remotesync func pre_configure_game():
	var selfPeerID = get_tree().get_network_unique_id()

	var world = load('res://Main.tscn').instance()

	var planet_name = \
		'planet_1' if get_tree().is_network_server() else 'planet_2'
	var my_planet = world.get_node(planet_name)
	my_planet.set_network_master(selfPeerID)

	var other_planet_name = \
		'planet_2' if get_tree().is_network_server() else 'planet_1'
	var other_planet = world.get_node(other_planet_name)
	other_planet.set_network_master(other_player_id)

	get_node('/root').add_child(world)

	rpc("done_preconfiguring", selfPeerID)
	get_tree().set_pause(true)


master func done_preconfiguring(who):
	assert(not who in players_done)

	players_done.append(who)

	if players_done.size() == 2:
		rpc("post_configure_game")


remotesync func post_configure_game():
	emit_signal('exit_lobby')


func traverse_nat(is_host):
	hole_puncher = preload('res://addons/Holepunch/holepunch_node.gd').new()
	hole_puncher.rendevouz_address = traversal_server_ip
	hole_puncher.rendevouz_port = traversal_server_port
	add_child(hole_puncher)
	hole_puncher.connect('session_registered', self, '_session_registered')
	var player_name = OS.get_unique_id()
	hole_puncher.start_traversal(game_code, is_host, player_name)
	var result = yield(hole_puncher, 'hole_punched')
	yield(get_tree().create_timer(0.1), 'timeout')
	return result

func generate_game_code():
	# use a local randomized RNG to keep the global RNG reproducible
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var length = 4
	var result = ''
	for _n in range(length):
		var ascii = rng.randi_range(0, 25) + 65
		result += '%c' % ascii
	return result

func _session_registered():
	emit_signal('update_status', 'Game Code: %s\nWaiting for other player...' % game_code)

# remove ourselves from the holepunch server before exiting
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST and is_instance_valid(hole_puncher):
		hole_puncher.checkout()
		if hole_puncher.is_host:
			hole_puncher.finalize_peers(game_code)
