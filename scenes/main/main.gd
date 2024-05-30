extends Node2D
@export var PlayerScene:PackedScene
@export var SpawnLocations:Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# index used to determine what spawn point a player will spawn on
	var index = 0
	
	# for every player in the list of players
	for i in GameManager.Players:
		
		# we instantiate a player object
		var currentPlayer:Node2D = PlayerScene.instantiate() as Node2D
		
		# we add it to the scene, making sure the node has a readable name
		add_child(currentPlayer,true)
		
		# we iterate through each spawn point
		for spawn:Node2D in SpawnLocations.get_children():
			
			# if the spawn points name is the same as our current index
			if spawn.name == str(index):
				
				#if our index is 0, set the color of the player to Red
				if index == 0: currentPlayer.modulate= Color.DARK_RED
				
				#else set it to Blue
				else: currentPlayer.modulate = Color.MEDIUM_BLUE
				
				#change the position of the player to that of the spawn point so that the player is now on the spawn point
				currentPlayer.global_position = spawn.global_position
				
				#send an RPC call to all peers to let them know who owns authority of the player that just got added the scene
				currentPlayer.set_authority.rpc(i)
		index+=1
