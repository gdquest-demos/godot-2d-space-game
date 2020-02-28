# Creates, maintains, and organizes spawned special effects or projectiles; 
# objects that should be untied from their spawners' lifespan when freed.
extends Node

var _effects: Node2D
var _projectiles: Node2D


func _ready() -> void:
	_effects = Node2D.new()
	add_child(_effects)
	_projectiles = Node2D.new()
	add_child(_projectiles)


func register_effect(effect: Node) -> void:
	_effects.add_child(effect)


func register_projectile(projectile: Node) -> void:
	_projectiles.add_child(projectile)
