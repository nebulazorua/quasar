class_name Conductor extends Node

signal beat_hit(b: float);
signal step_hit(s: float);
signal measure_hit(m: float);


var measure_length: float = 4.0; # In beats
var latency = AudioServer.get_output_latency();

@export var metronome_sound:AudioStreamPlayer;
@export var playing: bool = false;

@export var linked_audio_stream:AudioStreamPlayer;
@export var tempo: float = 120.0;

var bps: float = 0.0:
	get: return tempo / 60.0;

var crotchet: float = 0.0:
	get: return 60.0 / tempo
	
var time: float = 0.0;
var visual_time: float = 0.0;

var beat: float = 0.0;
var visual_beat: float = 0.0;

var step: float = 0 : 
	get: return step * 4;

var measure: float = 0 : 
	get: return beat / measure_length;

var beat_i: int = 0 : 
	get: return int(beat);

func update_time(time: float):
	
	var last_beat: int = beat_i;
	var last_step: int = int(step);
	var last_measure: int = int(measure);
	
	self.time = time;
	visual_time = time;
	
	beat = time * bps;
	visual_beat = visual_time * bps;
	
	var step_i: int = int(step);
	var measure_i: int = int(measure);
	if step_i > last_step:
		for step in range(last_step + 1, step_i + 1):
			step_hit.emit(step);
			
	if beat_i > last_beat:
		for beat in range(last_beat + 1, beat_i + 1):
			beat_hit.emit(beat);
		
		if is_instance_valid(metronome_sound):
			metronome_sound.play(0.0);
			
	if measure_i > last_measure:
		for measure in range(last_measure + 1, measure_i + 1):
			measure_hit.emit(measure);
			
var _last_time: float = 0.0;
	
func _process(delta: float):
	if is_instance_valid(linked_audio_stream) and linked_audio_stream.playing:
		var _last_mix: float = AudioServer.get_time_since_last_mix();
		var _time := linked_audio_stream.get_playback_position() + _last_mix
		if _time > _last_time:
			_last_time = _time;
		else:
			_time += delta;
			
		update_time(_time - latency)
	elif playing:
		update_time(self.time + delta)		
