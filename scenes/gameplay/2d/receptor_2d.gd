class_name Receptor2D extends Node2D
 # TODO: generic Receptor class which has nothing 2D or 3D related
# Also TODO: allow more customization within Receptor2D

@export var column:int = 0;

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer");

var _bot_glowed = false;

func _ready():
	$AnimationPlayer.animation_finished.connect(func(anim: StringName):
		if anim == 'confirm' && _bot_glowed:
			_bot_glowed = false;
			play_anim("idle");
	)
	
	
func play_anim(anim: String):
	animation_player.play(anim);
	animation_player.seek(0, true, true);
	
func bot_glow():
	animation_player.play(&"confirm");
	animation_player.seek(0, true, true);
	_bot_glowed = true;
