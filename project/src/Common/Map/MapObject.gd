extends Node2D


var acting_remote_transform: RemoteTransform2D


func setup(remote_transform: RemoteTransform2D, icon: Texture, modulate := Color.white, scale := 1.0) -> void:
	acting_remote_transform = remote_transform
	remote_transform.remote_path = get_path()
	$Sprite.texture = icon
	$Sprite.modulate = modulate
	$Sprite.scale = Vector2(scale, scale)


func clear() -> void:
	acting_remote_transform.remote_path = ""
