extends Node2D


var acting_remote_transform: RemoteTransform2D


func setup(remote_transform: RemoteTransform2D, icon: Texture) -> void:
	acting_remote_transform = remote_transform
	remote_transform.remote_path = get_path()
	$Sprite.texture = icon


func clear() -> void:
	acting_remote_transform.remote_path = ""
