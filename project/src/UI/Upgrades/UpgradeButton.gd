# Sets and controls the icon and label of the upgrade buttons. The tool keyword
# makes sure we can see the result in the editor.
tool
extends TextureButton

signal on_hide_complete;
signal on_show_complete;

export var texture: Texture setget set_texture
export var text := "" setget set_text

onready var texture_rect := $VBoxContainer/TextureRect
onready var label := $VBoxContainer/Label
onready var animation_player := $AnimationPlayer


func show_delayed(delay : float = 0) -> void:
	play_animation("show", delay)
	yield(animation_player, 'animation_finished')
	emit_signal("on_show_complete")


func hide_delayed(delay : float = 0) -> void:
	play_animation("hide", delay)
	yield(animation_player, 'animation_finished')
	emit_signal("on_hide_complete")


func play_animation(animation, delay) -> void:
	animation_player.set_assigned_animation(animation)
	animation_player.seek(0, true)
	yield(get_tree().create_timer(delay), "timeout")
	animation_player.play()
	
func set_texture(value: Texture) -> void:
	texture = value
	if not texture_rect:
		yield(self, "ready")
	texture_rect.texture = value


func set_text(value: String) -> void:
	text = value
	if not texture_rect:
		yield(self, "ready")
	label.text = value
	label.visible = text != ""
