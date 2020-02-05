extends Node


signal registry_group_changed(changed_group)


var _objects := {}
var _effects: Node2D
var _projectiles: Node2D


func _ready() -> void:
	_effects = Node2D.new()
	add_child(_effects)
	_projectiles = Node2D.new()
	add_child(_projectiles)


func register_node(node: Node, group: String) -> void:
	if not _objects.has(group):
		_objects[group] = []
	
	var group_objects: Array = _objects[group]
	group_objects.append(node)
	emit_signal("registry_group_changed", group)


func unregister_node_from(node: Node, group: String) -> void:
	if has_group(group) and _objects[group].has(node):
		var group_objects: Array = _objects[group]
		if group_objects.size() == 1:
			_objects.erase(group)
		else:
			group_objects.erase(node)
		
		emit_signal("registry_group_changed", group)


func has_group(group: String) -> bool:
	return _objects.has(group)


func get_nodes_from_group(group: String) -> Array:
	if not has_group(group):
		return []
	return _objects[group] as Array


func register_effect(effect: Node) -> void:
	_effects.add_child(effect)


func register_projectile(projectile: Node) -> void:
	_projectiles.add_child(projectile)
