# Controls the minimap viewport, and adding and removing proxy objects on the minimap.
class_name MapView
extends ViewportContainer

export var MapSprite: PackedScene = preload("res://src/UI/Minimap/MapSprite.tscn")

onready var sprites: Node2D = $Viewport/Sprites
onready var viewport: Viewport = $Viewport


func register_camera(camera: Camera2D) -> void:
	viewport.add_child(camera)


func register_map_object(remote_transform: RemoteTransform2D, icon: MapIcon) -> int:
	var map_object := MapSprite.instance()
	map_object.global_position = remote_transform.global_position

	sprites.add_child(map_object)
	map_object.setup(remote_transform, icon)

	return sprites.get_child_count()


func remove_map_object(id: int) -> void:
	if sprites.get_child_count() >= id:
		sprites.get_child(id).queue_free()
