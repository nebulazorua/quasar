extends Line2D

@onready var cap: Sprite2D = get_node("cap");

func update_cap():
	var last_point = get_point_position(get_point_count() - 1)
	var almost_last_point = get_point_position(get_point_count() - 2)
	
	cap.position = last_point;
	cap.position += almost_last_point.direction_to(last_point) * cap.texture.get_width() * 0.5
	
	cap.rotation = almost_last_point.angle_to_point(last_point)


@export var start_y:float = 0
@export var end_y:float = 0
	

var last_local_pos:Vector2;
		
func _process(_d: float):
	if not visible:
		return;
		
	global_position.y = start_y;
	var local_pos = to_local(Vector2(global_position.x, end_y - (cap.texture.get_width() * 0.5)));
	if local_pos.y < 0.0:
		local_pos.y = 0.0;
		
	if last_local_pos == null or last_local_pos.x != local_pos.x or last_local_pos.y != local_pos.y:
		set_point_position(1, local_pos)
		update_cap();
		
	last_local_pos = local_pos;
