extends Control


@export var player_name_input_field:LineEdit
@export var player_list:VBoxContainer
@export var join_button:Button
@export var ready_button:Button

func _ready():
	Client.client_has_connected_to_server.connect(_on_client_has_connected_to_server)
	Client.all_players_have_connected_to_server.connect(_on_all_players_have_connected_to_server)
	Client.player_ready_status_has_changed.connect(_on_player_ready_status_has_changed)
	
	GameManager.game_started.connect(_on_game_started)

	


func _create_ready_list():
	for player_id in GameManager.Players:
		var label:Label = Label.new()
		label.text= GameManager.Players[player_id].Name + ": " + GameManager.Players[player_id].Ready
		label.name = str(player_id)
		player_list.add_child(label)
	print("ready list created on client: " + str(multiplayer.get_unique_id()))
		
		

func _enable_ready_button():
	print("Ready button enabled on client: " + str(multiplayer.get_unique_id()))
	ready_button.disabled = false
	join_button.queue_free()


# called when user pressed the join button
func _on_join_button_pressed():
	join_button.disabled = true
	join_button.text = "Waiting for other player to join"
	Client.connect_client()


# called when user pressed the start game button
func _on_ready_button_pressed():
	# we make an rpc call on all players (server and clients) to create the main game scene
	Client.let_server_know_client_has_ready_uped()

	
func _on_client_has_connected_to_server():
	Client.send_player_data_to_server(player_name_input_field.text)	
	
	
func _on_player_ready_status_has_changed(player_id):
	
	#update the label to show that player is ready
	var player_labels:Array[Node] = player_list.get_children()
	for label:Label in player_labels:
		label.queue_free()
	if (multiplayer.get_unique_id() == player_id):
		ready_button.text = "Waiting for other player to Ready Up"
	_create_ready_list()
	

func _on_all_players_have_connected_to_server():
	_create_ready_list()
	_enable_ready_button()
	
func _on_game_started():
	hide()
