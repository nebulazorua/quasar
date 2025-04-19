extends CanvasLayer

@onready var bar := $ProgressBar;

var _twn:Tween;

var volume: float = 1 :
	set(v):
		if v > 1:
			v = 1
		elif v < 0:
			v = 0
			
		AudioServer.set_bus_volume_db(0, linear_to_db(v))
		AudioServer.set_bus_mute(0, v == 0)
		
		volume = v
		bar.value = volume
		
		if _twn != null:
			_twn.kill();
		
		_twn = create_tween()
		_twn.tween_property(self, "offset:y", 0, 0.05)
		_twn.tween_interval(1)
		_twn.tween_property(self, "offset:y", -80, 0.25)
		
		

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if not event.pressed or event.echo:
			return;
			
		
		if event.keycode == KEY_MINUS:
			volume -= 0.05;
		elif event.keycode == KEY_EQUAL:
			volume += 0.05;
