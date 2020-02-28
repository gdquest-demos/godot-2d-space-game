# Sets and controls the icon and label of the upgrade buttons. The tool keyword
# makes sure we can see the result in the editor.
tool
extends TextureButton

export var texture: Texture setget set_texture
export var text := "" setget set_text

onready var texture_rect := $VBoxContainer/TextureRect
onready var label := $VBoxContainer/Label


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
