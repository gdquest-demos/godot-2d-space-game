class_name LoopingAudioStreamPlayer2D
extends AudioStreamPlayer2D

export var start: AudioStream
export var loop: AudioStream
export var tail: AudioStream

var ending := false


func _ready() -> void:
	connect("finished", self, "_on_finished")


func start() -> void:
	stream = start
	ending = false
	play()


func end() -> void:
	stream = tail
	ending = true


func _on_finished() -> void:
	if stream == start:
		stream = loop
		play()
