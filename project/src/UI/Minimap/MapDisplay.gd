# Displays the MapView viewport on the screen, and animates it appearing and 
# disappearing
extends TextureRect

onready var _anim_player := $AnimationPlayer


func toggle() -> void:
	if visible:
		_anim_player.play("disappear")
	else:
		_anim_player.play("appear")
	Events.emit_signal("map_toggled", visible, _anim_player.current_animation_length)


func is_animating() -> bool:
	return _anim_player.is_playing()
