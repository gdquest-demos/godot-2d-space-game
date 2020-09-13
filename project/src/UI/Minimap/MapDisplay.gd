# Displays the MapView viewport on the screen, and animates it appearing and 
# disappearing
extends TextureRect

const AUDIO_STREAMS := {
	appear = preload("UI_Minimap_ZoomIn.wav"),
	disappear = preload("UI_Minimap_ZoomOut.wav"),
}

onready var _anim_player: AnimationPlayer = $AnimationPlayer
onready var _audio_player: AudioStreamPlayer = $AudioStreamPlayer


func toggle() -> void:
	if visible:
		_anim_player.play("disappear")
		_audio_player.stream = AUDIO_STREAMS.appear
		_audio_player.play()
	else:
		_anim_player.play("appear")
		_audio_player.stream = AUDIO_STREAMS.disappear
		_audio_player.play()
	Events.emit_signal("map_toggled", visible, _anim_player.current_animation_length)


func is_animating() -> bool:
	return _anim_player.is_playing()
