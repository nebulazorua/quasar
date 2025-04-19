class_name Note2D extends Node2D

const DIRECTIONS = [
	"left",
	"down",
	"up",
	"right"
];

var data: NoteData

	
func _process(delta: float):
	if not is_instance_valid(data) or data.scored:
		queue_free();
		return;
		
	if data.missed:
		modulate = Color(1, 1, 1).darkened(0.5)
		if position.y < -160 or position.y > 880:
			queue_free();
			return;
	else:
		modulate = Color(1, 1, 1);
		
			
	get_node("arrow").animation = DIRECTIONS[fmod(data.column, DIRECTIONS.size())] + " note"
