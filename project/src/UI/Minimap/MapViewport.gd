# Controls the addition and removal of proxy objects on the minimap.
extends Viewport

export var MapObject: PackedScene

var map_objects := {}

var _id := 0


func register_map_object(remote_transform: RemoteTransform2D, icon: MapIcon) -> int:
	var map_object := MapObject.instance()
	map_object.global_position = remote_transform.global_position

	var id := _get_next_id()
	map_objects[id] = map_object

	add_child(map_object)
	map_object.setup(remote_transform, icon)

	return id


func remove_map_object(id: int) -> void:
	if map_objects.has(id):
		map_objects[id].clear()
		map_objects[id].queue_free()
		map_objects.erase(id)


func _get_next_id() -> int:
	var id = _id
	_id += 1
	return id
