# Holds a sprite representation of itself and moves in the 
# minimap world using a remote transform that ties it to the original.
class_name MapSprite
extends Sprite

var acting_remote_transform: RemoteTransform2D


func setup(remote_transform: RemoteTransform2D, icon: MapIcon) -> void:
	acting_remote_transform = remote_transform
	remote_transform.remote_path = get_path()
	texture = icon.texture
	modulate = icon.color
	scale = Vector2(icon.scale, icon.scale)


func clear() -> void:
	acting_remote_transform.remote_path = ""
