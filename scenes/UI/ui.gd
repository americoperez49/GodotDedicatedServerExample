extends Control


@export var player_name_input_field:LineEdit
@export var player_list:VBoxContainer
@export var ready_button:Button

func _ready():
	Client.client_has_connected_to_server.connect(_on_client_has_connected_to_server)
	Client.all_players_have_connected_to_server.connect(_on_all_players_have_connected_to_server)

#anyone (client or server) can call this function and it will run both locally for the peer who called it and remotely for all other peers
@rpc("any_peer","call_local","reliable")		
func start_game():
	var scene:PackedScene = load("res://scenes/main/main.tscn") as PackedScene
	get_tree().root.add_child(scene.instantiate())
	hide()
	
	
@rpc("any_peer","call_local","reliable")
func ready_up(player_id:int):
	#assume all players are ready to start the game
	var all_players_are_ready = true
	
	#change the ready state of the player
	GameManager.Players[player_id].Ready = GameManager.READY_STATE.READY
	
	#update the label to show that player is ready
	var player_labels:Array[Node] = player_list.get_children()
	for label:Label in player_labels:
		if label.name == str(player_id):
			label.text = GameManager.Players[player_id].Name + ": Ready" 	
	
	#actually determine if all players are ready	
	for id in GameManager.Players:
		if GameManager.Players[id].Ready == GameManager.READY_STATE.NOT_READY:
			all_players_are_ready = false
	
	#start the game if all players are ready
	if all_players_are_ready:
		start_game.rpc()
	

func create_ready_list():
	for id in GameManager.Players:
		var label:Label = Label.new()
		label.text= GameManager.Players[id].Name + ": Not Ready" 
		label.name = str(id)
		player_list.add_child(label)
	print("ready list created on client: " + str(multiplayer.get_unique_id()))
		
		

func enable_ready_button():
	print("Ready button enabled on client: " + str(multiplayer.get_unique_id()))
	ready_button.disabled = false


# called when user pressed the join button
func _on_join_button_pressed():
	Client.connect_client()


# called when user pressed the start game button
func _on_ready_button_pressed():
	# we make an rpc call on all players (server and clients) to create the main game scene
	ready_up.rpc(multiplayer.get_unique_id())
	
func _on_client_has_connected_to_server():
	Client.send_player_data_to_server(player_name_input_field.text)	
	
	
func _on_all_players_have_connected_to_server():
	create_ready_list()
	enable_ready_button()
