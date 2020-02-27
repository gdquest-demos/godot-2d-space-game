tool
extends TextureButton

export var texture: Texture setget set_texture
export var text := "" setget set_text

onready var texture_rect := $VBoxContainer/TextureRect
onready var label := $VBoxContainer/Label


func set_texture(value: Texture) -> void:
	texture = value
	texture_rect.texture = value


func set_text(value: String) -> void:
	text = value
	label.text = value
	label.visible = text != ""
