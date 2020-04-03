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


func register_map_object(remote_transform: RemoteTransform2D, icon: MapIcon) -> MapSprite:
	var map_sprite: MapSprite = MapSprite.instance()
	map_sprite.global_position = remote_transform.global_position
	sprites.add_child(map_sprite)
	map_sprite.setup(remote_transform, icon)
	return map_sprite


func _on_Spawner_node_spawned(node: Node) -> void:
	if not node.is_in_group("mini-map"):
		return
	assert(node.has_node("MapTransform"))
	assert(node.get("map_icon") != null)
	var map_sprite := register_map_object(node.get_node("MapTransform"), node.map_icon)
	node.connect("tree_exiting", map_sprite, "queue_free")
