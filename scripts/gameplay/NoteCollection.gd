class_name NoteCollection extends Resource

# basically just an overcomplicated array specifically for notes LOL

const MAX_QUANT = 192; # Because you don't REALLY need to go beyond this
const ROWS_PER_BEAT: int = MAX_QUANT / 4;

@export var notes: Array[Dictionary] = [];
var length:int = 0;


func _init(columns:int = 4):
	notes.resize(columns);
	
func add_note(data: NoteData):
	notes[data.column].set(data.row, data);
	length += 1;

func get_notes_at_row(row: int):
	var collected_notes: Array[NoteData] = [];
	
	for n in notes:
		if n.has(row):
			collected_notes.push_back(n.get(row));
		
	return collected_notes;

# Chicken Jockey
#➖➖🟩🟩🟩🟩🟩🟩
#➖➖🟩🟩🟩🟩🟩🟩
#➖➖🟩🟩🟩🟩⬛⬛
#➖➖🟩🟩🟩🟩⬛⬛
#➖➖🟩🟩🟩🟩🟩🟩
#➖➖🟩🟩🟩🟩🟩🟩
#➖➖➖➖🟦🟦➖➖⬜⬜⬜⬜
#➖➖➖➖🟦🟦➖➖⬜⬜⬜⬜
#➖➖➖➖🟦🟦🟩🟩⬜⬜⬛⬛
#➖➖➖➖🟦🟦🟩🟩⬜⬜⬛⬛
#➖➖➖➖🟦🟦➖➖⬜⬜⬜⬜🟨🟨
#➖➖➖➖🟦🟦➖➖⬜⬜⬜⬜🟨🟨
#⬜⬜⬜⬜⬜⬜🟦🟦⬜⬜⬜⬜🟥🟥
#⬜⬜⬜⬜⬜⬜🟦🟦⬜⬜⬜⬜🟥🟥
#⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜
#⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜
#⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜
#⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜
#➖➖➖➖🟨🟨
#➖➖➖➖🟨🟨
#➖➖➖➖🟨🟨🟨🟨
#➖➖➖➖🟨🟨🟨🟨
