extends KinematicBody2D


signal damaged(amount)
signal player_dead


export var health := 100
export(int, LAYERS_2D_PHYSICS) var projectile_mask := 0
export var PopEffect: PackedScene

var can_dock := false
var _current_health := health
var dockable: Node2D

onready var shape := $CollisionShape
onready var agent: GSTSteeringAgent = $StateMachine/Move.agent
onready var effects_parent: Node2D = get_tree().get_nodes_in_group("Effects")[0]
onready var camera := $Camera2D


func _ready() -> void:
	connect("damaged", self, "_on_self_damaged")


func _on_self_damaged(amount: int) -> void:
	_current_health -= amount
	if _current_health <= 0:
		var effect := PopEffect.instance()
		effect.global_position = global_position
		effects_parent.add_child(effect)
		
		emit_signal("player_dead")
		
		remove_child(camera)
		get_parent().add_child(camera)
		camera.global_position = global_position
		
		queue_free()
