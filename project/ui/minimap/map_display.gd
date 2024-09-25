# Displays the MapView viewport on the screen, and animates it appearing and 
# disappearing
extends TextureRect

const AUDIO_STREAMS := {
	appear = preload("ui_minimap_zoom_in.wav"),
	disappear = preload("ui_minimap_zoom_out.wav"),
}

@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _audio_player: AudioStreamPlayer = $AudioStreamPlayer

# Viewports are still sort of buggy in Godot 4, 
# sometimes the path gets set to the Game scene's top-level object; GameInitializer
# so hard-coding it here...
func _ready() -> void:
	var t = texture as ViewportTexture
	t.viewport_path = "MapView"

func toggle() -> void:
	if visible:
		_anim_player.play("disappear")
		_audio_player.stream = AUDIO_STREAMS.appear
		_audio_player.play()
	else:
		_anim_player.play("appear")
		_audio_player.stream = AUDIO_STREAMS.disappear
		_audio_player.play()
	Events.map_toggled.emit(visible, _anim_player.current_animation_length)


func is_animating() -> bool:
	return _anim_player.is_playing()
