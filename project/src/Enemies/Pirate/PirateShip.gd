extends KinematicBody2D

# warning-ignore:unused_signal
signal damaged(amount, origin)
signal died
signal begin_patrol(patrol_point)
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
export var aggro_radius := 300.0
export var distance_from_spawn_max := 600.0
export var firing_angle_to_target := 4
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
onready var priority := GSAIPriority.new(agent)
onready var target_proximity := GSAIRadiusProximity.new(agent, [], distance_from_target_min)
onready var world_proximity := GSAIRadiusProximity.new(agent, [], distance_from_obstacles_min)
onready var spawn_location := GSAIAgentLocation.new()
onready var all_pirates_proximity := GSAIRadiusProximity.new(agent, [], 100)
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

	spawn_location.position.x = global_position.x
	spawn_location.position.y = global_position.y

	_setup_behaviors()

	# warning-ignore:return_value_discarded
	connect("damaged", self, "_on_self_damaged")
	# warning-ignore:return_value_discarded
	$AggroArea.connect("body_entered", self, "_on_AggroArea_body_entered")


func _physics_process(_delta: float) -> void:
	_set_behaviors_on_distances()
	_set_firing_on_target()

	#priority.calculate_steering(_acceleration)
	#agent._apply_steering(_acceleration, delta)


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
		all_pirates_proximity.agents.append(p.agent)
	emit_signal("initialized")


func setup_target(target: Node) -> void:
	if current_target == target:
		return
	if target:
		# warning-ignore:return_value_discarded
		target.connect("died", self, "_on_Target_died")
		target_agent = target.agent
		current_target = target
	else:
		target_agent = null
		current_target = null

	var pursue: GSAIPursue = _pursue_face_blend.get_behavior_at(0).behavior as GSAIPursue
	var face: GSAIFace = _pursue_face_blend.get_behavior_at(1).behavior as GSAIFace
	if target_agent:
		target_proximity.agents.append(target_agent)
	else:
		target_proximity.agents.clear()
	pursue.target = target_agent
	face.target = target_agent


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


func _set_behaviors_on_distances() -> void:
	var distance_from_spawn := agent.position.distance_to(spawn_location.position)

	if distance_from_spawn > distance_from_spawn_max or not target_agent:
		_arrive_home_blend.is_enabled = true
		_pursue_face_blend.is_enabled = false
		setup_target(null)
	else:
		if target_agent:
			var distance_from_target := agent.position.distance_to(target_agent.position)
			if distance_from_target < aggro_radius:
				_pursue_face_blend.is_enabled = true
				_arrive_home_blend.is_enabled = false


func _set_firing_on_target() -> void:
	if not target_agent:
		return

	if _pursue_face_blend.is_enabled:
		var to_target := (
			Vector2(agent.position.x, agent.position.y)
			- Vector2(target_agent.position.x, target_agent.position.y)
		)

		var angle_to_target := to_target.angle_to(GSAIUtils.angle_to_vector2(rotation))
		var comfortable_angle := deg2rad(firing_angle_to_target)
		if abs(angle_to_target) <= comfortable_angle:
			gun.fire(gun.global_position, rotation, projectile_mask)


func _setup_behaviors() -> void:
	var pursue := GSAIPursue.new(agent, target_agent)

	var face := GSAIFace.new(agent, target_agent)
	face.alignment_tolerance = deg2rad(5)
	face.deceleration_radius = deg2rad(45)

	_pursue_face_blend = GSAIBlend.new(agent)
	_pursue_face_blend.add(pursue, 1)
	_pursue_face_blend.add(face, 1)
	_pursue_face_blend.is_enabled = false

	var separation := GSAISeparation.new(agent, target_proximity)
	separation.decay_coefficient = pow(target_proximity.radius, 2) / 0.15

	_pursue_face_blend.add(separation, 2)

	var avoid := GSAIAvoidCollisions.new(agent, world_proximity)

	var arrive := GSAIArrive.new(agent, spawn_location)
	arrive.arrival_tolerance = 200
	arrive.deceleration_radius = 300
	var look := GSAILookWhereYouGo.new(agent)
	look.alignment_tolerance = deg2rad(5)
	look.deceleration_radius = deg2rad(45)

	_arrive_home_blend = GSAIBlend.new(agent)
	_arrive_home_blend.add(arrive, 1)
	_arrive_home_blend.add(look, 1)
	_arrive_home_blend.is_enabled = false

	priority.add(avoid)
	priority.add(_arrive_home_blend)
	priority.add(_pursue_face_blend)


func _on_self_damaged(amount: int, origin: Node) -> void:
	_health -= amount
	setup_target(origin)

	if _health <= 0:
		_die()

	_health -= amount
	if _health <= 0:
		_pursue_face_blend.is_enabled = false
		_arrive_home_blend.is_enabled = true


func _on_Target_died() -> void:
	setup_target(null)


func _on_AggroArea_body_entered(body: PhysicsBody2D) -> void:
	if not target_agent:
		setup_target(body)
