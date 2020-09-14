class_name MenuSoundPlayer
extends AudioStreamPlayer

export var sound_close: AudioStream
export var sound_confirm: AudioStream
export var sound_hide: AudioStream
export var sound_open: AudioStream
export var sound_select: AudioStream


func play_close() -> void:
	stream = sound_close
	play()


func play_confirm() -> void:
	stream = sound_confirm
	play()


func play_hide() -> void:
	stream = sound_hide
	play()


func play_open() -> void:
	stream = sound_open
	play()


func play_select() -> void:
	stream = sound_select
	play()
