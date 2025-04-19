class_name NoteData extends Object

# TODO: merge scored and missed into one score thing (score = MISSED)
var scored: bool = false;
var missed: bool = false;

var beat: float = 0.0;
var column: int = 0;
var length: float = 0.0;

var row: int = 0 :
	get:
		return beat * NoteCollection.ROWS_PER_BEAT

func _init(b:float = 0.0, c:int = 0, l:float = 0.0) -> void:
	beat = b;
	column = c;
	length = l;
