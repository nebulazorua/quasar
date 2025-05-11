class_name Player extends Node

# TODO: rewrite in C#

signal scored_note(data: NoteData);
signal missed_note(data: NoteData);

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
				

var hold_index:int = 0;
var last_miss_check:int = 0;
var last_autoplay_row:int = 0;
func _process(dt:float):
	_check_spawns();
	var miss_beat := (conductor.time - 0.18) * conductor.bps;
	var row:int = conductor.beat * NoteCollection.ROWS_PER_BEAT;
	# Autoplay
	if auto_played and row > last_autoplay_row:
		var notes: Array[NoteData] = note_data.get_notes_between(last_autoplay_row, row)
		for data in notes:
			if not data.scored:
				if is_instance_valid(hit_sound):
					hit_sound.play(0);
				score_note(data, 0);
				confirm(data.column);
	
	last_autoplay_row = row;
	
	# Update Misses
			
	for miss_row in range(last_miss_check - 48, row): # doing it based on last_miss_check because lag spikes etc
		for n in note_data.notes:
			var data = n.get(miss_row, null);
			if data != null and data.beat <= miss_beat and not data.scored and not data.missed:
				data.missed = true;
				misses += 1;
				missed_note.emit(data)
				
	# TODO: Update holds
	
			#if note.data.length > 0:
			#var start_pos := note_y;
			#var end_beat := data.beat + data.length;
			#var end_pos: float = target_y + get_y_pos(end_beat);
			#
			#if data.scored and data.hold_time < data.length:
				#start_pos = target_y;
				#
				#var last_hit_steps = ceil(data.hold_time * 4);
				#data.hold_time = conductor.beat - data.beat;
				#
				#if auto_played or Input.is_action_pressed("column_%s" % data.column):
					#data.drop_progress = 1.0;
				#else:
					#data.drop_progress -= dt / 0.1;
					#
				#if last_hit_steps < ceil(data.hold_time * 4):
					#if auto_played:
						#receptors[data.column].bot_glow()
					#elif Input.is_action_pressed("column_%s" % data.column):
						#confirm(data.column)
					#
				#if data.drop_progress <= 0:
					#data.missed = true;
	last_miss_check = row;
		
#endregion
