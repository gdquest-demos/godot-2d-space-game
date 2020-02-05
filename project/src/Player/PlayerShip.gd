extends KinematicBody2D


signal damaged(amount)
signal player_dead


export var health_max := 100
export(int, LAYERS_2D_PHYSICS) var projectile_mask := 0
export var PopEffect: PackedScene

var can_dock := false
var _health := health_max
var dockable: Node2D

onready var shape := $CollisionShape
onready var agent: GSTSteeringAgent = $StateMachine/Move.agent
onready var camera := $Camera2D


func _ready() -> void:
	connect("damaged", self, "_on_self_damaged")
	ObjectRegistry.register_node(self, "Player")


func die() -> void:
	var effect := PopEffect.instance()
	effect.global_position = global_position
	ObjectRegistry.register_effect(effect)

	emit_signal("player_dead")
	
	ObjectRegistry.unregister_node_from(self, "Player")

	queue_free()


func _on_self_damaged(amount: int) -> void:
	_health -= amount
	if _health <= 0:
		die()
