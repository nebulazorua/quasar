class_name Note2D extends Node2D

const DIRECTIONS = [
	"left",
	"down",
	"up",
	"right"
];

var data: NoteData

@onready var arrow:AnimatedSprite2D = get_node("arrow")
@onready var hold: Line2D = get_node("hold")

func change_hold(start_y: float, end_y: float):
	hold.start_y = start_y;
	hold.end_y = end_y;
	
func _process(delta: float):
	if not is_instance_valid(data):
		visible = false;
		queue_free();
		return;
		
	arrow.visible = not data.scored;
	
	#if data.scored and (data.length <= 0 or data.hold_time >= data.length):
	if data.scored:
		visible = false;
		queue_free();
		return;
		
	if data.missed:
		modulate = Color(0.5, 0.5, 0.5);
		if position.y < -160 or position.y > 880:
			visible = false;
			queue_free();
			return;
	else:
		modulate = Color(1, 1, 1);
		
	hold.visible = data.length > 0
	arrow.animation = DIRECTIONS[fmod(data.column, DIRECTIONS.size())] + " note"
