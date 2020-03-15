# Controls the minimap viewport, and adding and removing proxy objects on the minimap.
class_name MapView
extends ViewportContainer

export var MapSprite: PackedScene = preload("res://src/UI/Minimap/MapSprite.tscn")

onready var sprites: Node2D = $Viewport/Sprites
onready var viewport: Viewport = $Viewport

func _ready() -> void:
	Events.connect("node_spawned", self, "_on_Spawner_node_spawned")


func register_camera(camera: Camera2D) -> void:
	viewport.add_child(camera)


func register_map_object(remote_transform: RemoteTransform2D, icon: MapIcon) -> int:
	var map_sprite := MapSprite.instance()
	map_sprite.global_position = remote_transform.global_position

	sprites.add_child(map_sprite)
	map_sprite.setup(remote_transform, icon)

	return sprites.get_child_count() - 1


func remove_map_object(id: int) -> void:
	if sprites.get_child_count() > id:
		sprites.get_child(id).queue_free()


func _on_Spawner_node_spawned(node: Node) -> void:
	if not node.is_in_group("mini-map"):
		return
	assert(node.has_node("MapTransform"))
	assert(node.get("map_icon") != null)
	var id := register_map_object(node.get_node("MapTransform"), node.map_icon)
	node.connect("tree_exiting", self, "remove_map_object", [id])
