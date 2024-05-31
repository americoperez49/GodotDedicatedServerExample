extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# utility function just so we can see who (server or clients) is printing the debug statements
func _who_created_this_message(peer):
	print ("Peer " + str(peer.get_unique_id()) + " created the following message:")
