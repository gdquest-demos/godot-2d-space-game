class_name LoopingAudioStreamPlayer2D
extends AudioStreamPlayer2D

export var sound_start: AudioStream
export var sound_loop: AudioStream
export var sound_tail: AudioStream

var ending := false


func _ready() -> void:
	connect("finished", self, "_on_finished")


func start() -> void:
	stream = sound_start
	ending = false
	play()


func end() -> void:
	stream = sound_tail
	ending = true


func _on_finished() -> void:
	if stream == sound_start:
		stream = sound_loop
		play()
