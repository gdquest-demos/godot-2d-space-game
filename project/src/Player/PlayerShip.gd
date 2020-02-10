extends KinematicBody2D


signal damaged(amount)
signal died


export var map_icon: Texture
export var health_max := 100
export(int, LAYERS_2D_PHYSICS) var projectile_mask := 0
export var PopEffect: PackedScene

var can_dock := false
var dockable: Node2D
var _health := health_max

onready var shape := $CollisionShape
onready var agent: GSTSteeringAgent = $StateMachine/Move.agent
onready var remote_transform := $RemoteTransform2D
onready var timer := $Timer
onready var cargo := $Cargo


func _ready() -> void:
	connect("damaged", self, "_on_self_damaged")
	$Gun.projectile_mask = projectile_mask
	$StateMachine/Move/Dock.connect("docked", cargo, "_on_Player_docked")
	$StateMachine/Move/Dock.connect("undocked", cargo, "_on_Player_undocked")


func toggle_map(map_up: bool, tween_time: float) -> void:
	if not map_up:
		timer.start(tween_time)
		yield(timer, "timeout")
	remote_transform.update_position = not map_up


func die() -> void:
	var effect := PopEffect.instance()
	effect.global_position = global_position
	ObjectRegistry.register_effect(effect)

	emit_signal("died")

	queue_free()


func register_on_map(map: Viewport) -> void:
	var id: int = map.register_map_object($MapTransform, map_icon)
	connect("died", map, "remove_map_object", [id])


func _on_self_damaged(amount: int) -> void:
	_health -= amount
	if _health <= 0:
		die()
