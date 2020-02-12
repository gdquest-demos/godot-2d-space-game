extends Node2D


var acting_remote_transform: RemoteTransform2D

onready var sprite: Sprite = $Sprite


func setup(
	remote_transform: RemoteTransform2D,
	icon: Texture,
	modulate := Color.white,
	scale := 1.0
) -> void:
	acting_remote_transform = remote_transform
	remote_transform.remote_path = get_path()
	sprite.texture = icon
	sprite.modulate = modulate
	sprite.scale = Vector2(scale, scale)


func clear() -> void:
	acting_remote_transform.remote_path = ""
