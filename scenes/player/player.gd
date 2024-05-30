extends Node2D
@export var MultiplayerSync:MultiplayerSynchronizer
@export var PlayerNameLabel:Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

@rpc("any_peer","call_local")
func set_authority(id):
	#sets the name of the player so it shows over the players head
	PlayerNameLabel.text = GameManager.Players[id].Name
	
	# tells the client that the client should be the authority for this node and all of its children.
	# this means that the client dictates what everyone else sees. Not the server.
	# we only really do this to make things easier.
	# In practice, we dont want to do this because then its easy for players to cheat.
	set_multiplayer_authority(id)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# we check to make sure that we have authority over the node.
	# the server will only have authority over its resepdtive player
	# the client will only have authority over their respective player
	# if we have authority over the node, then we are allowed to manipulate the node ( i.e. move and change color)
	if is_multiplayer_authority():
		if Input.is_action_pressed("ui_right"):
			global_position.x += 3
		if Input.is_action_pressed("ui_left"):
			global_position.x -= 3
		if Input.is_action_pressed("ui_down"):
			global_position.y += 3
		if Input.is_action_pressed("ui_up"):
			global_position.y -= 3
		if Input.is_action_just_pressed("ui_accept"):
			modulate = Color(randf_range(0.0,2.0),randf_range(0.0,2.0),randf_range(0.0,2.0))
