# Base script that represents the physics body of a pirate ship. Manages the 
# pirate's squad, squad leader, and movement speeds of the ship.
class_name PirateShip
extends CharacterBody2D

signal died
signal squad_leader_changed(current_patrol_point)

const DECELERATION_RADIUS := deg_to_rad(45)
const ALIGNMENT_TOLERANCE := deg_to_rad(5)

# Represents the ship on the minimap. Use a MapIcon resource.
@export var map_icon: Resource

@export var health_max := 100

@export var linear_speed_max := 200.0
@export var acceleration_max := 15.0
@export var drag_factor := 0.04
@export var angular_speed_max := 270
@export var angular_acceleration_max := 15
@export var angular_drag_factor := 0.1
@export var distance_from_target_min := 200.0
@export var distance_from_obstacles_min := 200.0
@export var projectile_mask := 0 # (int, LAYERS_2D_PHYSICS)
@export var explosion_effect: PackedScene

var current_target: Node
var target_agent: GSAISteeringAgent
var squaddies: Array

var is_squad_leader := false
var patrol_point := Vector2.ZERO
var squad_leader: CharacterBody2D

var agent := await GSAICharacterBody2DAgent.new(self)
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

@onready var gun := $Gun
@onready var state_machine := $StateMachine


func _ready() -> void:
	rng.randomize()
	# ----- Agent config -----
	agent.linear_acceleration_max = acceleration_max
	agent.linear_speed_max = linear_speed_max

	agent.angular_acceleration_max = deg_to_rad(angular_acceleration_max)
	agent.angular_speed_max = deg_to_rad(angular_speed_max)

	agent.bounding_radius = (MathUtils.get_triangle_circumcircle_radius($CollisionShape3D.polygon))

	agent.linear_drag_percentage = drag_factor
	agent.angular_drag_percentage = angular_drag_factor

	Events.damaged.connect(_on_self_damaged)
	Events.target_aggroed.connect(_on_Target_Aggroed)
	
	$AggroArea.body_entered.connect(_on_Body_entered_aggro_radius)


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
	_squad_leader: CharacterBody2D,
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
		Events.squad_leader_changed.connect(_on_Leader_changed)


func setup_faction(pirates: Array) -> void:
	for p in pirates:
		faction_proximity.agents.append(p.agent)


func _die() -> void:
	var effect: Node2D = explosion_effect.instantiate()
	ObjectRegistry.register_effect(effect)
	effect.global_position = global_position
	died.emit()
	var new_leader: CharacterBody2D
	for squaddie_ref in squaddies:
		var squaddie: CharacterBody2D = squaddie_ref.get_ref()
		if not squaddie:
			continue
		# FIXME: I had an error because a Projectile was in the squaddies array
		# We should ensure this cannot happen, and squaddies are all from the faction
		if not squaddie.is_in_group("Enemies"):
			continue
		if squaddie._health > 0:
			new_leader = squaddie
			break
	Events.squad_leader_changed.emit(self, new_leader, patrol_point)

	queue_free()


func _on_self_damaged(target: Node, amount: int, _origin: Node) -> void:
	if not target == self:
		return

	_health -= amount

	if _origin:
		Events.target_aggroed.emit(squad_leader, _origin)

	if _health <= 0:
		_die()


func _on_Leader_changed(
	old_leader: CharacterBody2D, new_leader: CharacterBody2D, current_patrol_point: Vector2
) -> void:
	if old_leader == squad_leader:
		squaddies.erase(old_leader)
		squad_proximity.agents.erase(old_leader.agent)
		squad_leader = new_leader
		if new_leader == self:
			is_squad_leader = true
			patrol_point = current_patrol_point
		squad_leader_changed.emit(current_patrol_point)


func _on_Body_entered_aggro_radius(collider: PhysicsBody2D) -> void:
	Events.target_aggroed.emit(squad_leader, collider)


func _on_Target_Aggroed(leader: Node, target: PhysicsBody2D) -> void:
	if squad_leader == leader:
		state_machine.transition_to("Attack", {target = target})
