class_name Gameplay extends Node2D

@onready var conductor: Conductor = $conductor;
@onready var music: AudioStreamPlayer = $music;
@export var song_name: String = "sporting";

func _ready():	
	var chart = Chart.new().parse_legacy_chart("res://resources/gameplay/songs/%s/%s.json" % [song_name, song_name]);
	conductor.tempo = chart.tempo;
	
	# TODO: some metadata shit to get inst and vox etc lol
	var stream: AudioStreamSynchronized = AudioStreamSynchronized.new();
	stream.set_sync_stream(0, load("res://resources/gameplay/songs/%s/Inst.ogg" % song_name));
	stream.set_sync_stream(1, load("res://resources/gameplay/songs/%s/Voices.ogg" % song_name));
	stream.stream_count += 2;
	music.stream = stream;
	
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
				player.scroll_speed = chart.raw_data.speed;
			else:
				player.scroll_speed = UserSettings.speed
	
	player.auto_played = false;
	opponent.auto_played = true;
	
	player.downscroll = UserSettings.reverse
			
	opponent.scroll_method = Player.ScrollMethod.FNF
	opponent.scroll_speed = chart.raw_data.speed;
	
	$opponent.note_data = chart.player_notes[0];
	$player.note_data = chart.player_notes[1];
	
	conductor.update_time(-5 / conductor.bps);
	conductor.playing = true;
	
func _process(delta:float):
	if conductor.time >= 0 and not music.playing:
		music.play();
