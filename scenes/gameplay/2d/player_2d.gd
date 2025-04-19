# NOTE: it's likely that alot of this will likely be rewritten in C#

class_name Player2D extends Player

# TODO: move alot of this into NoteDisplay2D and Player

@export var spacing:float = 64; # TODO: determine from notestyle or hudstyle


@onready var judgement: JudgementSprite = get_node("judgement")
@onready var receptors_node: Node2D = get_node("receptors")
@onready var notes_node: Node2D = get_node("notes")

var receptors: Array[Receptor2D] = [];

func _ready():
	# TODO: determine this all with like a note style resource
	if !is_instance_valid(conductor) and get_parent().has_node("conductor"):
		conductor = get_parent().get_node("conductor");
		
	receptors.resize(receptors_node.get_child_count());
	
	for receptor: Receptor2D in receptors_node.get_children():
		receptors[receptor.column] = receptor;

func set_downscroll(v):
	receptors_node.position.y = 56;
	if v:
		receptors_node.global_position.y = 720 - receptors_node.global_position.y;



func spawn_note(data: NoteData):
	var note: Note2D = note_template.instantiate();
	note.data = data;
	notes_node.add_child(note);


func release(column:int):
	receptors[column].play_anim("idle")
	
func ghost_tap(column:int):
	receptors[column].play_anim("tap")
	
func confirm(column: int):
	receptors[column].play_anim("confirm");


func display_judgement(index: int, note: NoteData):		

	# TODO: dont hardcode this shit
	
	var colours: Array[Color] = [
		Color("a215ba"),
		Color("00ffff"),
		Color("12fa05"),
		Color("e26823"),
		Color("ff0000")
	];
	var judge_colour := colours[index];
		
	receptors[note.column].modulate = judge_colour
	judgement.show_judge(index);
	
	return index;
		
func _process(dt:float):
	super._process(dt);
	
	var miss_beat := (conductor.time - 0.18) * conductor.bps;
	
	# TODO: Make this rely on note data and move it into the global Player class instead
	
	for note: Note2D in notes_node.get_children():

		if auto_played and note.data.beat <= conductor.beat and not note.data.scored:
			if is_instance_valid(hit_sound):
				hit_sound.play(0);
			score_note(note.data, 0);
			receptors[note.data.column].bot_glow()
			
		if note.data.beat < miss_beat and not note.data.scored and not note.data.missed:
			note.data.missed = true;
			misses += 1;
			judgement.show_judge(5);
		
		var reverse_mod: float = -1 if downscroll else 1
		
		note.global_position.y = receptors[note.data.column].global_position.y;
		
		match scroll_method:
			ScrollMethod.CMOD:
				var time:float = note.data.beat / conductor.bps;
				var bps:float = (scroll_speed * 1.515) / 60.0;
				note.position.y += (time - conductor.visual_time) * bps * spacing * reverse_mod
			ScrollMethod.XMOD:
				note.position.y += (note.data.beat - conductor.visual_beat) * spacing * scroll_speed * reverse_mod
			ScrollMethod.FNF:
				var time:float = note.data.beat / conductor.bps;
				note.position.y += (time - conductor.visual_time) * 450 * scroll_speed * reverse_mod
			
				
		note.position.x = receptors[note.data.column].position.x;
	
	$Label.text = 'misses: %d / accuracy: %.3f%%' % [misses, (hit_notes / note_data.length) * 100]
