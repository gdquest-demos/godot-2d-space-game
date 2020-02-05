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
onready var effects_parent: Node2D = (
		get_tree().get_nodes_in_group("Effects")[0]
				if get_tree().get_nodes_in_group("Effects").size() > 0
				else null
)
onready var camera := $Camera2D


func _ready() -> void:
	connect("damaged", self, "_on_self_damaged")


func die() -> void:
	var effect := PopEffect.instance()
	effect.global_position = global_position
	effects_parent.add_child(effect)

	emit_signal("player_dead")

	remove_child(camera)
	get_parent().add_child(camera)
	camera.global_position = global_position

	queue_free()


func _on_self_damaged(amount: int) -> void:
	_health -= amount
	if _health <= 0:
		die()
