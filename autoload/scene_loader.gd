extends Node

# TODO: transitions

func switch_to(path: String):
	if not path.begins_with("res://"):
		path = "res://%s" % path;
	
	get_tree().call_deferred("change_scene_to_file", path)
	
