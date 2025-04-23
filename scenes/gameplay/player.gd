class_name Player extends Node

signal scored_note(data: NoteData);
signal released_input(column: int);
signal ghost_tapped(column:int);

enum ScrollMethod {
	CMOD = 0,
	XMOD = 1,
	FNF = 2
}

@export var downscroll:bool = false :
	set(v):
		set_downscroll(v);
		downscroll = v;
		
@export var note_template:PackedScene;
@export var auto_played:bool = false;
@export var hit_sound:AudioStreamPlayer;
@export var conductor:Conductor;
@export var scroll_method:ScrollMethod = ScrollMethod.CMOD
@export var scroll_speed:float = 400; # What this should be depends on scroll method
var note_data: NoteCollection
var _last_spawned_row:int = 0;

var hit_notes:float = 0;
var misses:int = 0;


#region Per-Dimension Implementations
func set_downscroll(scroll:bool):
	print_rich("[color=orange][b]WARNING:[b] Unimplemented 'set_downscroll' function");
	
func spawn_note(data: NoteData):
	print_rich("[color=red][b]URGENT:[b] Unimplemented 'spawn_note' function!!")
	
func release(column:int):
	print_rich("[color=orange][b]WARNING:[b] Unimplemented 'release' function")

func ghost_tap(column:int):
	print_rich("[color=orange][b]WARNING:[b] Unimplemented 'ghost_tap' function")

func confirm(column: int):
	print_rich("[color=orange][b]WARNING:[b] Unimplemented 'confirm' function")

func display_judgement(index: int, note: NoteData):		
	print_rich("[color=orange][b]WARNING:[b] Unimplemented 'display_judgement' function")
	
func score_note(note: NoteData, diff: float = (note.beat / conductor.bps) - conductor.time ):		
	if note.scored:
		return;
		
	var judged_diff: float = abs(diff) * 1000.0; # ENSURE it's absolute and also ms
	note.scored = true;
	if note.length > 0:
		note.drop_progress = 1;
		
	# TODO: make this less hardcoded
	var j_idx := 4;
	
	var judge_timings: Array[float] = [22.5, 45, 90, 135, 180];
	var judge_scores: Array[float] = [1, 0.9, 0.67, 0.34, 0]
	
	for idx in range(0, judge_timings.size()):
		if judged_diff <= judge_timings[idx]:
			j_idx = idx;
			break;
	
	hit_notes += judge_scores[j_idx];
	display_judgement(j_idx, note);
	scored_note.emit(note);
	
		
	
	
#endregion

#region Global Player stuff
func get_note_spawn_beat():
	return (conductor.time + 1) * conductor.bps; # TODO: take into account scroll speeds
	# Can likely do some dumb math to figure out the current latest row, convert to beat then like +0.25 or something

func _check_spawns():
	# TODO: some sorta get_spawn_beat func and take into acc scrollspeed etc
	
	var spawn_beat: float = get_note_spawn_beat();
	var spawn_row:int = spawn_beat * NoteCollection.ROWS_PER_BEAT;
	
	for c in range(0, 4):
		for i in range(_last_spawned_row, spawn_row):
			if note_data.notes[c].has(i):
				spawn_note(note_data.notes[c].get(i))
		
	_last_spawned_row = spawn_row;


func _unhandled_input(event: InputEvent) -> void:
	if auto_played:
		return;
		
	if event.is_echo():
		return;
		
	if event is InputEventKey:
		for column in range(0, 4):
			if event.is_action("column_%s" % [column]):
				if event.is_pressed():
					if is_instance_valid(hit_sound):
						hit_sound.play(0);
					# TODO: bug test and perhaps optimize if required
					
					var scan_back: float = conductor.beat - ((conductor.time - 0.18) * conductor.bps);
					var scan_forward: float = ((conductor.time + 0.18) * conductor.bps) - conductor.beat;
					var back_row:int = scan_back * NoteCollection.ROWS_PER_BEAT;
					var front_row:int = scan_forward * NoteCollection.ROWS_PER_BEAT;
					
					# stepmania shit idk lmao
					# not rlly required but i wanna make sure its consistent on both sides forward and back
					var search_rows: int = max(back_row, front_row);
					
					var song_row := conductor.beat * NoteCollection.ROWS_PER_BEAT;
					
					var hit_note: bool = false;
					#receptors[column].play_anim("tap")
					for row in range(song_row - search_rows, song_row + search_rows + 1):
						var note:NoteData = note_data.notes[column].get(row);
						if note != null and not note.scored:
							# TODO: proper judging
							confirm(note.column)
							score_note(note);
							hit_note = true;
							break;
					
					if not hit_note:
						ghost_tap(column);
						ghost_tapped.emit();
						
				else:
					release(column);
					released_input.emit(column);
					#receptors[column].play_anim("idle")	
				break;
				
func _process(dt:float):
	_check_spawns();
	
#endregion
