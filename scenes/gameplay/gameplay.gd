class_name Gameplay extends Node2D

@onready var conductor: Conductor = $conductor;
@onready var music: AudioStreamPlayer = $music;

func _ready():
	# TODO: make an actual chart class
	
	var json_data: Dictionary = load("res://resources/gameplay/songs/sporting/sporting-hard.json").data.song
	conductor.tempo = json_data.bpm;
	var player_notes = NoteCollection.new(4);
	var opponent_notes = NoteCollection.new(4);
	for section_data in json_data.notes:
		var section_notes: Array[Variant] = section_data.sectionNotes;
		for note in section_notes:
			var time:float = note[0] / 1000.0;
			var column_id:int = note[1];
			var hold_length: float = note[2] / 1000.0;
			if column_id < 0:
				continue; # thanks psych engine
				
			var gotta_hit = section_data.mustHitSection;
			if (column_id % 8 > 3):
				gotta_hit = !gotta_hit;
			
			if gotta_hit:
				player_notes.add_note(
					NoteData.new(time * conductor.bps, fmod(column_id, 4))
				)
			else:
				opponent_notes.add_note(
					NoteData.new(time * conductor.bps, fmod(column_id, 4))
				)
				
	var player := $player;
	var opponent := $opponent;
	
	if UserSettings.opp:
		opponent = $player;
		player = $opponent;
	
	player.scroll_method = UserSettings.method;
	match UserSettings.method:
		Player.ScrollMethod.CMOD:
			player.scroll_speed = UserSettings.cmod
		Player.ScrollMethod.XMOD:
			player.scroll_speed = UserSettings.xmod
		Player.ScrollMethod.FNF:
			if UserSettings.speed == 0.0:
				player.scroll_speed = json_data.speed;
			else:
				player.scroll_speed = UserSettings.speed
	
	player.auto_played = false;
	opponent.auto_played = true;
	
	player.downscroll = UserSettings.reverse
			
	opponent.scroll_method = Player.ScrollMethod.FNF
	opponent.scroll_speed = json_data.speed;
	
	$player.note_data = player_notes;
	$opponent.note_data = opponent_notes;
	
	conductor.update_time(-5 / conductor.bps);
	conductor.playing = true;
	
func _process(delta:float):
	if conductor.time >= 0 and not music.playing:
		music.play();
