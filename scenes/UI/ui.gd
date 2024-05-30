extends Control

var IP_ADDRESS = "localhost"
var PORT = 8910
var MAX_NUMBER_OF_PLAYERS = 2
var peer:ENetMultiplayerPeer
@export var player_name_input_field:LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	#we connect to all of the signals that will be fired when certain events occur
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	

# called on server and client when a peer connects
# we dont really need this function for this example.
# Just had it here for debug purposes
func _on_peer_connected(ID):
	_who_created_this_message()
	print("Peer connected: " + str(ID) + "\n")
	
# called on server and client when a peer disconnects
# we dont really need this function for this example.
# Just had it here for debug purposes
func _on_peer_disconnected(ID):
	_who_created_this_message()
	print("Peer disconnected: " + str(ID) + "\n")

#only called on client when a peer has successfully established a connection to the server
func _on_connected_to_server():
	_who_created_this_message()
	print("conntected to server" + "\n")
	
	#client will send their player information to the server
	send_player_data.rpc_id(1,multiplayer.get_unique_id(),player_name_input_field.text)

#only called on client when a peer has unsuccessfully established a connection to the server
# we dont really need this function for this example.
# Just had it here for debug purposes
func _on_connection_failed():
	_who_created_this_message()
	print("connection failed" + "\n")

#anyone (client or server) can call this function and it will run both locally for the peer who called it and remotely for all other peers
@rpc("any_peer","call_local","reliable")		
func start_game():
	var scene:PackedScene = load("res://scenes/main/main.tscn") as PackedScene
	get_tree().root.add_child(scene.instantiate())
	hide()

# technically anyone (client or server) can call this function but it will NOT run locally. it will only run remotely for all other peers.
# The way everything is currently implemented, a client makes an RPC call to this function but the client specifies that it only wants the RPC 
# function to run specifically on the server by calling send_player_data.rpc_id(1,id,name)  (see line 34 for code example)
# from there, the server makes the RPC call on all other clients by calling send_player_data.rpc(id,name)
@rpc("any_peer")
func send_player_data(ID,Name):
	#if the peer's list of players doesnt contain the player we just receieved data for, then add them to the list
	if !GameManager.Players.has(ID):
		GameManager.Players[ID]= {
			"ID":ID,
			"Name":Name
		}
	
	#if we are the server, then call this RPC function on all other clients, passing new player info to all clients
	if multiplayer.is_server():
		for id in GameManager.Players:
			send_player_data.rpc(id,GameManager.Players[id].Name)
			print()

		

#called when user presses the host button
func _on_host_button_pressed():
	# we create a new peer object
	peer = ENetMultiplayerPeer.new()
	
	# we create the server
	var error = peer.create_server(PORT,MAX_NUMBER_OF_PLAYERS)
	if error != OK:
		print("cannot host: " + error)
		return
	# If all went OK then we set the peer of our Godot instance to the peer that we just created
	multiplayer.multiplayer_peer=peer
	
	_who_created_this_message()
	print("waiting for other players" + "\n")
	
	# we call the function directly here. Not an RPC call.
	# This adds ourselves (the server) to the list of players
	# only add this here if you are using P2P networking
	send_player_data(multiplayer.get_unique_id(),player_name_input_field.text)


# called when user pressed the join button
func _on_join_button_pressed():
	# we create a new peer object
	peer =ENetMultiplayerPeer.new()
	
	# we create a new client and connect to the server using its IP and PORT
	peer.create_client(IP_ADDRESS,PORT)
	multiplayer.multiplayer_peer=peer


# called when user pressed the start game button
func _on_start_game_button_pressed():
	# we make an rpc call on all players (server and clients) to create the main game scene
	start_game.rpc()
	pass # Replace with function body.
	
# utility function just so we can see who (server or clients) is printing the debug statements
func _who_created_this_message():
	print ("Peer " + str(peer.get_unique_id()) + " created the following message:")
