# Creates, maintains, and organizes spawned special effects or projectiles; 
# objects that should be untied from their spawners' lifespan when freed.
extends Node

onready var _effects := $Effects
onready var _projectiles := $Projectiles
onready var _distortions: Viewport


func register_effect(effect: Node) -> void:
	_effects.add_child(effect)


func register_projectile(projectile: Node) -> void:
	_projectiles.add_child(projectile)


func register_distortion_effect(effect: Node2D) -> void:
	if _distortions:
		_distortions.add_child(effect)


func register_distortion_parent(viewport: Viewport) -> void:
	_distortions = viewport
