class_name MenuSoundPlayer
extends AudioStreamPlayer

export var sound_close: AudioStream
export var sound_confirm: AudioStream
export var sound_hide: AudioStream
export var sound_open: AudioStream
export var sound_select: AudioStream

var _current_sound := stream setget _set_current_sound

func play_close() -> void:
	self._current_sound =sound_close
	play()


func play_confirm() -> void:
	self._current_sound =sound_confirm
	play()


func play_hide(delay := 0.0) -> void:
	self._current_sound =sound_hide
	if delay > 0.0:
		yield(get_tree().create_timer(delay), "timeout")
	play()


func play_open(delay := 0.0) -> void:
	self._current_sound =sound_open
	if delay > 0.0:
		yield(get_tree().create_timer(delay), "timeout")
	play()


func play_select() -> void:
	self._current_sound =sound_select
	play()


func _set_current_sound(value: AudioStream) -> void:
	if value != _current_sound:
		_current_sound =value
		stream = _current_sound
