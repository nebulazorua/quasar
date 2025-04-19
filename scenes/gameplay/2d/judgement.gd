class_name JudgementSprite extends Sprite2D

var velocity: Vector2 = Vector2.ZERO;
var acceleration: Vector2 = Vector2.ZERO;

var _fade_tween:Tween;

func show_judge(judge:int):
	if is_instance_valid(_fade_tween):
		_fade_tween.kill();
			
	modulate.a = 1.0;
	_fade_tween = create_tween()
	_fade_tween.tween_interval(1 / get_parent().conductor.bps)
	_fade_tween.tween_property(self, "modulate:a", 0, 0.2)
	_fade_tween.tween_callback(func():
		visible = false;
	);
	frame = judge;
	visible = true;
	position.y = 280;
	position.x = 0;
	
	velocity = Vector2(
		floor((randf() - 0.5) * 20),
		-floor(randf_range(140, 175))
	)
	acceleration.y = 550;

func _physics_process(delta: float) -> void:
	velocity += acceleration * delta * 0.5;
	position += velocity * delta;
	velocity += acceleration * delta * 0.5;
	
