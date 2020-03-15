# Base script that represents the physics body of a pirate ship. Manages the 
# pirate's squad, squad leader, and movement speeds of the ship.
class_name PirateShip
extends KinematicBody2D

signal died
signal squad_leader_changed(current_patrol_point)

const DECELERATION_RADIUS := deg2rad(45)
const ALIGNMENT_TOLERANCE := deg2rad(5)

# Represents the ship on the minimap. Use a MapIcon resource.
export var map_icon: Resource

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
export var ExplosionEffect: PackedScene

var current_target: Node
var target_agent: GSAISteeringAgent
var squaddies: Array

var is_squad_leader := false
var patrol_point := Vector2.ZERO
var squad_leader: KinematicBody2D

var agent := GSAIKinematicBody2DAgent.new(self)
var squad_proximity := GSAIInfiniteProximity.new(agent, [])
var target_proximity := GSAIRadiusProximity.new(agent, [], distance_from_target_min)
var world_proximity := GSAIRadiusProximity.new(agent, [], distance_from_obstacles_min)
var faction_proximity := GSAIRadiusProximity.new(agent, [], 500)
var rng := RandomNumberGenerator.new()

var _acceleration := GSAITargetAcceleration.new()
var _velocity := Vector2.ZERO
var _angular_velocity := 0.0
var _arrive_home_blend: GSAIBlend
var _pursue_face_blend: GSAIBlend
var _health := health_max

onready var gun := $Gun
onready var state_machine := $StateMachine


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

	Events.connect("damaged", self, "_on_self_damaged")

	$AggroArea.connect("body_entered", self, "_on_Body_entered_aggro_radius")

	Events.connect("target_aggroed", self, "_on_Target_Aggroed")


func setup_world_objects(world_objects: Array) -> void:
	world_proximity.agents.clear()
	for wo_ref in world_objects:
		var wo: Node2D = wo_ref.get_ref()
		if not wo:
			continue
		var object_agent: GSAIAgentLocation = wo.agent_location
		world_proximity.agents.append(object_agent)


func setup_squad(
	_is_squad_leader: bool,
	_squad_leader: KinematicBody2D,
	_patrol_point: Vector2,
	_squaddies: Array
) -> void:
	is_squad_leader = _is_squad_leader
	squad_leader = _squad_leader
	patrol_point = _patrol_point
	var squaddies_ref := []
	for s in _squaddies:
		squad_proximity.agents.append(s.agent)
		squaddies_ref.append(weakref(s))
	squaddies = squaddies_ref
	if not is_squad_leader:
		Events.connect("squad_leader_changed", self, "_on_Leader_changed")


func setup_faction(pirates: Array) -> void:
	for p in pirates:
		faction_proximity.agents.append(p.agent)


func _die() -> void:
	var effect: Node2D = ExplosionEffect.instance()
	effect.global_position = global_position
	ObjectRegistry.register_effect(effect)
	emit_signal("died")
	var new_leader: KinematicBody2D
	for squaddie_ref in squaddies:
		var squaddie: KinematicBody2D = squaddie_ref.get_ref()
		if not squaddie:
			continue
		# FIXME: I had an error because a Projectile was in the squaddies array
		# We should ensure this cannot happen, and squaddies are all from the faction
		if not squaddie.is_in_group("Enemies"):
			continue
		if squaddie._health > 0:
			new_leader = squaddie
			break
	Events.emit_signal("squad_leader_changed", self, new_leader, patrol_point)

	queue_free()


func _on_self_damaged(target: Node, amount: int, _origin: Node) -> void:
	if not target == self:
		return

	_health -= amount

	if _health <= 0:
		_die()


func _on_Leader_changed(
	old_leader: KinematicBody2D, new_leader: KinematicBody2D, current_patrol_point: Vector2
) -> void:
	if old_leader == squad_leader:
		squaddies.erase(old_leader)
		squad_proximity.agents.erase(old_leader.agent)
		squad_leader = new_leader
		if new_leader == self:
			is_squad_leader = true
			patrol_point = current_patrol_point
		emit_signal("squad_leader_changed", current_patrol_point)


func _on_Body_entered_aggro_radius(collider: PhysicsBody2D) -> void:
	Events.emit_signal("target_aggroed", squad_leader, collider)


func _on_Target_Aggroed(leader: Node, target: PhysicsBody2D) -> void:
	if squad_leader == leader:
		state_machine.transition_to("Attack", {target = target})
