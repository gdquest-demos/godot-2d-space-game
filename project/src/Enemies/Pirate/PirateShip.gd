extends KinematicBody2D

# warning-ignore:unused_signal
signal damaged(amount, origin)
signal died
signal begin_patrol
signal end_patrol
signal initialized

const DECELERATION_RADIUS := deg2rad(45)
const ALIGNMENT_TOLERANCE := deg2rad(5)

export var map_icon: Texture
export var color_map_icon := Color.white
export var scale_map_icon := 0.75

export var health_max := 100

export var linear_speed_max := 200.0
export var acceleration_max := 15.0
export var drag_factor := 0.04
export var angular_speed_max := 270
export var angular_acceleration_max := 15
export var angular_drag_factor := 0.1
export var distance_from_target_min := 200.0
export var distance_from_obstacles_min := 200.0
export (int, LAYERS_2D_PHYSICS) var projectile_mask := 0
export var PopEffect: PackedScene

var _acceleration := GSAITargetAcceleration.new()
var _velocity := Vector2.ZERO
var _angular_velocity := 0.0
var _arrive_home_blend: GSAIBlend
var _pursue_face_blend: GSAIBlend
var _health := health_max
var current_target: Node
var target_agent: GSAISteeringAgent

var is_squad_leader := false
var patrol_point := Vector2.ZERO
var squad_leader: KinematicBody2D

onready var gun: Gun = $Gun

onready var agent := GSAIKinematicBody2DAgent.new(self)
onready var squad_proximity := GSAIInfiniteProximity.new(agent, [])
onready var target_proximity := GSAIRadiusProximity.new(agent, [], distance_from_target_min)
onready var world_proximity := GSAIRadiusProximity.new(agent, [], distance_from_obstacles_min)
onready var faction_proximity := GSAIRadiusProximity.new(agent, [], 500)
onready var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	# ----- Agent config -----
	agent.linear_acceleration_max = acceleration_max
	agent.linear_speed_max = linear_speed_max
	
	agent.angular_acceleration_max = deg2rad(angular_acceleration_max)
	agent.angular_speed_max = deg2rad(angular_speed_max)
	
	agent.bounding_radius = (MathUtils.get_triangle_circumcircle_radius($CollisionShape.polygon))
	
	agent.linear_drag_percentage = drag_factor
	agent.angular_drag_percentage = angular_drag_factor

	# warning-ignore:return_value_discarded
	connect("damaged", self, "_on_self_damaged")
	# warning-ignore:return_value_discarded
	$AggroArea.connect("body_entered", self, "_on_AggroArea_body_entered")


func setup_world_objects(world_objects: Array) -> void:
	for wo in world_objects:
		var object_agent: GSAIAgentLocation = wo.agent_location
		if object_agent and not world_proximity.agents.has(object_agent):
			world_proximity.agents.append(object_agent)


func setup_squad(
	_is_squad_leader: bool, _squad_leader: KinematicBody2D, _patrol_point: Vector2, squaddies: Array
) -> void:
	is_squad_leader = _is_squad_leader
	squad_leader = _squad_leader
	patrol_point = _patrol_point
	for s in squaddies:
		squad_proximity.agents.append(s.agent)


func setup_faction(pirates: Array) -> void:
	for p in pirates:
		faction_proximity.agents.append(p.agent)
	emit_signal("initialized")


func register_on_map(map: Viewport) -> void:
	var id: int = map.register_map_object($MapTransform, map_icon, color_map_icon, scale_map_icon)
	# warning-ignore:return_value_discarded
	connect("died", map, "remove_map_object", [id])


func _die() -> void:
	var effect: Node2D = PopEffect.instance()
	effect.global_position = global_position
	ObjectRegistry.register_effect(effect)
	emit_signal("died")
	queue_free()


func _on_self_damaged(amount: int, origin: Node) -> void:
	_health -= amount

	if _health <= 0:
		_die()

	_health -= amount
	if _health <= 0:
		_pursue_face_blend.is_enabled = false
		_arrive_home_blend.is_enabled = true
