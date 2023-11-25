extends Node

#Signal is emitted when holepunch is complete. Connect this signal to your network manager
#Once your network manager received the signal they can host or join a game on the host port
signal hole_punched(my_port, hosts_port, hosts_address)

#This signal is emitted when the server has acknowledged your client registration, but before the
#address and port of the other client have arrived.
signal session_registered;
# signal to update network status externally
signal broadcast_status(state, msg);
# signal to update stage externally
signal broadcast_stage(stage);

var server_udp = PacketPeerUDP.new()
var peer_udp = PacketPeerUDP.new()

#Set the rendevouz address to the IP address of your third party server
@export var rendevouz_address:String=""
#Set the rendevouz port to the port of your third party server
@export var rendevouz_port:int=4000
#This is the range of ports you will search if you hear no response from the first port tried
@export var port_cascade_range:int=10
#The amount of messages of the same type you will send before cascading or giving up
@export var response_window:int=24;
#The amount of receives that will flag that a peer is still requesting
@export var receive_window:int=2;

var found_server = false
var recieved_peer_info = false

var is_host = false

var own_port
var peers={};
var peers_cache={};
var host_address = ""
var host_port = 0
var client_name
var p_timer
var session_id

var ports_tried = 0

const REGISTER_SESSION = "rs:"
const REGISTER_CLIENT = "rc:"
const EXCHANGE_PEERS = "ep:"
const CHECKOUT_CLIENT = "cc:"
const PEER_GREET = "greet"
const PEER_CONFIRM = "confirm"
const PEER_GO = "go"
const SERVER_OK = "ok"
const SERVER_INFO = "peers"

var MAX_PLAYER_COUNT=GameDataManager.SAVEDATA.number_players;

# warning-ignore:unused_argument
func _process(delta):
	if peer_udp.get_available_packet_count() > 0:
		var array_bytes = peer_udp.get_packet()
		var packet_string = array_bytes.get_string_from_ascii()
		print("\n============================================ received:", packet_string);		
		if packet_string.begins_with(PEER_GREET):
			var m = packet_string.split(":");
			if (m[1] in peers.keys()): # anti-cascade
				print("handling peer_greet :", [m[1], m[2], m[3]], "as (p.name, p.port, s.port)");
				_handle_greet_message(m[1], int(m[2]), int(m[3]));
		
		if packet_string.begins_with(PEER_CONFIRM):
			var m = packet_string.split(":");
			if (m[2] in peers.keys()):
				print("handling peer_confirm :", [m[2], m[1], m[4], m[3]], "as (p.name, p.port, s.port, is_host)");
				_handle_confirm_message(m[2], m[1], m[4], m[3])
		
		if packet_string.begins_with(PEER_GO):
			var m = packet_string.split(":");
			if (m[1] in peers.keys()):
				print("handling peer_go :", [m[1]], "as (name)");
				_handle_go_message(m[1])

	if server_udp.get_available_packet_count() > 0:
		var array_bytes = server_udp.get_packet()
		var packet_string = array_bytes.get_string_from_ascii()
		print("RAW[0]=", packet_string);
		if packet_string.begins_with(SERVER_OK):
			var m = packet_string.split(":")
			own_port = int( m[1] )
			emit_signal('session_registered')
			print("@server_ok , own_port=", own_port);
			if is_host:
				if !found_server:
					_send_client_to_server()
			found_server=true

		if not recieved_peer_info:
			if packet_string.begins_with(SERVER_INFO):
				server_udp.close()
				packet_string = packet_string.right(-6)
				if (packet_string.length() > 2):
					print("PACKET STRING :", [packet_string]);
					var client_peers=packet_string.split(",", false);
					if (client_peers.size()<1):
						print("Invalid info[0] received.");
						# emit!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
						return;
					print("CPEERS :", client_peers);
					for pkt_string in client_peers:
						print("------------------------------");
						var m = pkt_string.split(":");
						if (len(m)<3):
							print("Invalid info[1] received.");
							# emit!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
							return;
						print("@server_info: m=", m);
						peers[m[0]] = {
							"port":m[2], 
							"address":m[1], 
							"confirm":{"sent":false, "received":false}, # semt_to_peer, rec_from_peer
							"greet":{"sent":false, "received":false},
							 "go":{"sent":false, "received":false},
							"greets_sent":0,
							"confirms_sent":0,
							"greets_received":0,
							"confirms_received":0,
							"gos_sent":0,
							};
						recieved_peer_info = true;
						start_peer_contact()
					print("NEW PEER LIST :", peers);
					peers_cache=peers.duplicate(true);

func _handle_greet_message(peer_name, peer_port, my_port):
	if (peers[peer_name].greets_received>=receive_window): # peer still pinging
		#peers[peer_name].greet.received=false;
		#peers[peer_name].greets_received=0;
		#return;
		pass;
	
	if own_port != my_port:
		own_port = my_port
		peer_udp.close()
		peer_udp.bind(own_port, "*")
	if (!peers[peer_name].greet.sent): # send greet before expecting one back
		print("Greet declined");
		return;
	peers[peer_name].greet.received=true;
	peers[peer_name].greets_received+=1;
	print("Greet accepted");

func _handle_confirm_message(peer_name, peer_port, my_port, peer_is_host):
	if (peers[peer_name].confirms_received>=receive_window): # peer still pinging
		#peers[peer_name].confirm.received=false;
		#peers[peer_name].confirms_received=0;
		#return;
		pass;
		
	if (peers[peer_name].port!=peer_port):
		peers[peer_name].port = peer_port
	peers[peer_name].is_host = peer_is_host
	print("@focus ; peer_name=<", peer_name, "> =>", peers[peer_name], "|", peers[peer_name]["is_host"]);
	if (str(peer_is_host).to_lower()=="true"):
		print("marking host_data of ", peer_name, ">", peer_is_host);
		host_address = peers[peer_name].address
		host_port = peers[peer_name].port
	peer_udp.close()
	peer_udp.bind(own_port, "*");
	if (!peers[peer_name].confirm.sent): # send greet before expecting one back
		print("Confirm declined");
		return;
	peers[peer_name].confirm.received=true;
	peers[peer_name].confirms_received+=1;
	print("Confirm accepted");

func _handle_go_message(peer_name):
	if (!peers[peer_name].go.sent):
		print("Go declined");
		return;
	print("Go accepted");
	peers[peer_name].go.received=true;
	
	var received_all_gos=true;
	for p in peers.keys():
		received_all_gos=(received_all_gos && peers[p].go.received);
	if (received_all_gos):
		_exit_procedure();
		print("<<<<<<>>>>>>>>>>>>")

func _exit_procedure():
	# steps to stop timer and process when connection is no longer needed
	emit_signal("hole_punched", int(own_port), int(host_port), host_address)
	peer_udp.close();
	p_timer.stop()
	set_process(false)

func _cascade_peer(add, peer_port):
	for i in range(peer_port - port_cascade_range, peer_port + port_cascade_range):
		peer_udp.set_dest_address(add, i)
		var buffer=PackedByteArray();
		buffer.append_array(("greet:"+client_name+":"+str(own_port)+":"+str(i)).to_utf8_buffer())
		peer_udp.put_packet(buffer)
		ports_tried += 1

func _ping_peer():
	"""
	sends handshakes to peer by
	sending signal if not yet sent or not received due to dropped/missed
	"""
	for p in peers.keys():
		var peer=peers[p];
		print(">>>>NOW AT peer=", peer);
		# if greet not sent to PEER or greet not yet rec from PEER
		if (!peer.confirm.received):
			if (peer.greets_sent<response_window):
				peer_udp.set_dest_address(peers[p].address, int(peers[p].port))
				var buffer=PackedByteArray();
				buffer.append_array(("greet:"+client_name+":"+str(own_port)+":"+peers[p].port).to_utf8_buffer())
				print("sending greeting to <"+peers[p].port+"> with msg="+buffer.get_string_from_utf8());
				peer_udp.put_packet(buffer);
				emit_signal('broadcast_stage', PEER_GREET);
				peer.greet.sent=true;
			elif (peer.greets_sent==response_window):
				print("Receiving no confirm. Starting port cascade")
				print("Cascading for peer");
				_cascade_peer(peers[p].address, int(peers[p].port));
			peer.greets_sent+=1;		
		if (peer.greet.received && !peer.go.received):
			peer_udp.set_dest_address(peers[p].address, int(peers[p].port))
			var buffer=PackedByteArray();
			buffer.append_array(("confirm:"+str(own_port)+":"+client_name+":"+str(is_host)+":"+peers[p].port).to_utf8_buffer())
			print("sending confirm to <"+peers[p].port+"> with msg="+buffer.get_string_from_utf8());
			peer_udp.put_packet(buffer);
			peer.confirm.sent=true;
			emit_signal('broadcast_stage', PEER_CONFIRM);
			peer.confirms_sent+=1;
		if (peer.confirm.received):
			peer_udp.set_dest_address(peers[p].address, int(peers[p].port))
			var buffer=PackedByteArray();
			buffer.append_array(("go:"+client_name).to_utf8_buffer())
			print("sending go to <"+peers[p].port+"> with msg="+buffer.get_string_from_utf8());
			peer_udp.put_packet(buffer);
			peer.go.sent=true;
			emit_signal('broadcast_stage', PEER_GO);
			peer.gos_sent+=1;
		
		# ensure that look isn't indefinite
		if (peer.greets_sent>response_window*3 || peer.confirms_sent>response_window*3):
			print("Exited ping due to unresponsive peer");
			emit_signal('broadcast_status', false, 'Failed to connect (%s)'%Parameter.FAIL.CLI);
			p_timer.stop();
			break;
	
	# since goes have no confirm, don't leave them open forever
	# if all gos are received OR one received but other exceeded OR all exceeded
	var go_state={}; # -v use a key-pair approach
	for p in peers.keys():
		if (peers[p].gos_sent>response_window):
			go_state[p]="exceeded";
		if (peers[p].go.received):
			go_state[p]="received";
	
	#the other players have confirmed and are probably waiting
	if (len(go_state)==len(peers)):
		_exit_procedure();

func start_peer_contact():	
	server_udp.put_packet("goodbye".to_utf8_buffer())
	server_udp.close();
	if peer_udp.is_bound():
		peer_udp.close()
	var err = peer_udp.bind(own_port, "*")
	if err != OK:
		print("Error listening on port: " + str(own_port) +" Error: " + str(err))
	p_timer.start()

#this function can be called to the server if you want to end the holepunch before the server closes the session
func finalize_peers(id):
	var buffer=PackedByteArray();
	buffer.append_array((EXCHANGE_PEERS+str(id)).to_utf8_buffer())
	server_udp.set_dest_address(rendevouz_address, rendevouz_port)
	server_udp.put_packet(buffer)

# remove a client from the server
func checkout():
	var buffer=PackedByteArray();
	buffer.append_array((CHECKOUT_CLIENT+client_name).to_utf8_buffer())
	server_udp.set_dest_address(rendevouz_address, rendevouz_port)
	server_udp.put_packet(buffer)

#Call this function when you want to start the holepunch process
func start_traversal(id, is_player_host, player_name):
	print("@traversal");
	if server_udp.is_bound(): # server listening
		server_udp.close();

	print("binding...");
	var err = server_udp.bind(rendevouz_port, "*");
	if (err!=OK):
		print("Error listening on port: " + str(rendevouz_port) + " to server: " + rendevouz_address)
		emit_signal('broadcast_status', false, 'Failed to connect (%s)'%Parameter.FAIL.PORT);
		return false;
	is_host = is_player_host
	client_name = player_name
	found_server = false
	recieved_peer_info = false
	
	peers = {}
	ports_tried = 0
	session_id = id
	
	if (is_host):
		print("@is_host");
		var buffer=PackedByteArray();
		var msg=(REGISTER_SESSION+session_id+":"+str(MAX_PLAYER_COUNT));
		print("MSG : ", msg);
		buffer.append_array(msg.to_utf8_buffer());
		server_udp.close()
		err=server_udp.set_dest_address(rendevouz_address, rendevouz_port);
		print("Err =", err, [rendevouz_address, rendevouz_port]);
		if(err!=OK):
			print("Failed to set dest with value=", err);
			emit_signal('broadcast_status', false, 'Failed to connect (%s)'%Parameter.FAIL.DEST);
			return false;
		err=server_udp.put_packet(buffer);
		if (err!=OK):
			print("Failed to put packet with value=", err);
			emit_signal('broadcast_status', false, 'Failed to connect (%s)'%Parameter.FAIL.PUT);
			return false;
		print("put_packet...");
	else:
		return await _send_client_to_server();
	emit_signal('broadcast_status', true, 'Contacting server...');
	return true;

#Register a client with the server
func _send_client_to_server():
	await get_tree().create_timer(2.0).timeout;
	var buffer=PackedByteArray();
	buffer.append_array((REGISTER_CLIENT+client_name+":"+session_id).to_utf8_buffer())
	server_udp.close()
	var err=server_udp.set_dest_address(rendevouz_address, rendevouz_port);
	if(err!=OK):
		print("Failed to set dest with value=", err);
		emit_signal('broadcast_status', false, 'Failed to connect (%s)'%Parameter.FAIL.DEST);
		return false;
	err=server_udp.put_packet(buffer);
	if (err!=OK):
		print("Failed to put packet with value=", err);
		emit_signal('broadcast_status', false, 'Failed to connect (%s)'%Parameter.FAIL.PUT);
		return false;
	emit_signal('broadcast_status', true, 'Contacting server...');
	return true;

func _exit_tree():
	server_udp.close()

func _ready():
	p_timer = Timer.new();
	get_node("/root/").call_deferred("add_child", p_timer);
	p_timer.timeout.connect(_ping_peer);
	p_timer.wait_time=0.1;

# greet_sent=(greets_sent>0)
