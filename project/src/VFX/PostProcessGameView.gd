tool
extends TextureRect


func _ready() -> void:
	visible = not Engine.editor_hint
