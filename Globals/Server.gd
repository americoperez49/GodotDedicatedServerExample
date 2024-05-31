extends Node

var IP_ADDRESS = "localhost"
var PORT = 8910
var MAX_NUMBER_OF_PLAYERS = 2
var peer:ENetMultiplayerPeer

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.has_feature("dedicated_server"):
		host_game()
		


func host_game():
	# we create a new peer object
	peer = ENetMultiplayerPeer.new()
	
	# we create the server
	var error = peer.create_server(PORT,MAX_NUMBER_OF_PLAYERS)
	if error != OK:
		print("cannot host: " + error)
		return
	# If all went OK then we set the peer of our Godot instance to the peer that we just created
	multiplayer.multiplayer_peer=peer
	
	Utils._who_created_this_message(peer)
	print("waiting for other players" + "\n")

@rpc("authority","call_remote","reliable")
func send_player_data_to_clients(players):
	print("Player data arrived at client")
	GameManager.Players = players
	pass

@rpc("any_peer","reliable")
func gather_player_data(ID,Name):
	print("Client: " + str(ID) + " has connected to server")
		#if the peer's list of players doesnt contain the player we just receieved data for, then add them to the list
	if !GameManager.Players.has(ID):
		GameManager.Players[ID]= {
			"ID":ID,
			"Name":Name,
			"Ready":GameManager.READY_STATE.NOT_READY,
			"Added_To_Scene":false
		}
		
	if _two_players_have_connected():
		print("letting clients know that two players have connected and that they can show the ready list and enable the ready button")
		Client.all_players_have_connected.rpc(GameManager.Players)
	pass
	
func _two_players_have_connected():
	return GameManager.Players.size() == 2


