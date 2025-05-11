class_name Chart extends Resource

@export var player_notes: Array[NoteCollection] = [];
@export var events: Array[Dictionary] = []; # TODO: event class
@export var tempo: float = 100.0;
@export var raw_data: Dictionary;

# TODO: make GoonChart
func parse_legacy_chart(chart_path:String):
	var json_data: Dictionary = load(chart_path).data.song;
	raw_data = json_data;
	tempo = json_data.bpm;
	var bps := tempo / 60.0;
	
	player_notes.append(NoteCollection.new(4)) # Opponent
	player_notes.append(NoteCollection.new(4)) # Player
	
	for section_data in json_data.notes:
		var section_notes: Array[Variant] = section_data.sectionNotes;
		for note in section_notes:
			var time:float = note[0] / 1000.0;
			var column_id:int = note[1];
			var hold_length_sex: float = note[2] / 1000.0;
			var hold_length_bts: float = 0; #hold_length_sex * bps;
			
			if column_id < 0:
				continue; # thanks psych engine
				
			var gotta_hit = section_data.mustHitSection;
			if (column_id % 8 > 3):
				gotta_hit = !gotta_hit;
			
			if gotta_hit:
				player_notes[1].add_note(
					NoteData.new(time * bps, fmod(column_id, 4), hold_length_bts)
				)
			else:
				player_notes[0].add_note(
					NoteData.new(time * bps, fmod(column_id, 4), hold_length_bts)
				)
				
	return self;
