# Sets and controls the icon and _label of the upgrade buttons. The tool keyword
# makes sure we can see the result in the editor.
tool
extends TextureButton

signal appeared;
signal disappeared;

export var texture: Texture setget set_texture
export var text := "" setget set_text

onready var _texture_rect := $VBoxContainer/TextureRect
onready var _label := $VBoxContainer/Label
onready var _animation_player := $AnimationPlayer


func appear(delay : float = 0) -> void:
	_play_animation("show", delay)


func disappear(delay : float = 0) -> void:
	_play_animation("hide", delay)


func _play_animation(animation, delay) -> void:
	_animation_player.set_assigned_animation(animation)
	_animation_player.seek(0, true)
	yield(get_tree().create_timer(delay), "timeout")
	_animation_player.play()


func set_texture(value: Texture) -> void:
	texture = value
	if not _texture_rect:
		yield(self, "ready")
	_texture_rect.texture = value


func set_text(value: String) -> void:
	text = value
	if not _texture_rect:
		yield(self, "ready")
	_label.text = value
	_label.visible = text != ""


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"show":
			emit_signal("appeared")
		"hide":
			emit_signal("disappeared")
