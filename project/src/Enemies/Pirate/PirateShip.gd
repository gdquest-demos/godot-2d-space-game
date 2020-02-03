extends KinematicBody2D


export var linear_speed_max := 200.0
export var acceleration_max := 15.0
export var drag_factor := 0.04
export var angular_speed_max := 270
export var angular_acceleration_max := 15
export var angular_drag_factor := 0.1
export var distance_from_player_min := 200.0
export var distance_from_obstacles_min := 200.0
export var aggro_radius := 300.0
export var distance_from_spawn_max := 600.0

var _acceleration := GSTTargetAcceleration.new()
var _velocity := Vector2.ZERO
var _angular_velocity := 0.0
var _arrive_home_blend: GSTBlend
var _pursue_face_blend : GSTBlend

onready var agent := GSTSteeringAgent.new()
onready var player_agent: GSTSteeringAgent = get_tree().get_nodes_in_group("Player")[0].agent
onready var priority := GSTPriority.new(agent)
onready var player_proximity := GSTRadiusProximity.new(
		agent,
		[player_agent],
		distance_from_player_min
)
onready var world_proximity := GSTRadiusProximity.new(
		agent,
		[],
		distance_from_obstacles_min
)
onready var spawn_location := GSTAgentLocation.new()


func _ready() -> void:
	agent.linear_acceleration_max = acceleration_max
	agent.linear_speed_max = linear_speed_max
	agent.angular_acceleration_max = angular_acceleration_max
	agent.angular_speed_max = angular_speed_max
	agent.bounding_radius = MathUtils.get_triangle_circumcircle_radius($CollisionShape.polygon)
	_update_agent()
	spawn_location.position.x = global_position.x
	spawn_location.position.y = global_position.y
	
	var pursue := GSTPursue.new(agent, player_agent)
	
	var face := GSTFace.new(agent, player_agent)
	face.alignment_tolerance = deg2rad(5)
	face.deceleration_radius = deg2rad(45)
	
	_pursue_face_blend = GSTBlend.new(agent)
	_pursue_face_blend.add(pursue, 1)
	_pursue_face_blend.add(face, 1)
	_pursue_face_blend.is_enabled = false
	
	var separation := GSTSeparation.new(agent, player_proximity)
	separation.decay_coefficient = pow(player_proximity.radius, 2)/0.15
	
	_pursue_face_blend.add(separation, 2)
	
	var avoid := GSTAvoidCollisions.new(agent, world_proximity)

	var arrive := GSTArrive.new(agent, spawn_location)
	arrive.arrival_tolerance = 200
	arrive.deceleration_radius = 300
	var look := GSTLookWhereYouGo.new(agent)
	look.alignment_tolerance = deg2rad(5)
	look.deceleration_radius = deg2rad(45)

	_arrive_home_blend = GSTBlend.new(agent)
	_arrive_home_blend.add(arrive, 1)
	_arrive_home_blend.add(look, 1)
	_arrive_home_blend.is_enabled = false
	
	priority.add(avoid)
	priority.add(_arrive_home_blend)
	priority.add(_pursue_face_blend)
	
	var world_objects := get_tree().get_nodes_in_group("World_Objects")
	for wo in world_objects:
		var object_agent: GSTAgentLocation = wo.agent_location
		if object_agent:
			world_proximity.agents.append(object_agent)


func _physics_process(delta: float) -> void:
	_update_agent()

	var distance_from_spawn := agent.position.distance_to(spawn_location.position)

	if distance_from_spawn > distance_from_spawn_max:
		_arrive_home_blend.is_enabled = true
		_pursue_face_blend.is_enabled = false
	else:
		var distance_from_player := agent.position.distance_to(player_agent.position)
		if distance_from_player < aggro_radius:
			_pursue_face_blend.is_enabled = true
			_arrive_home_blend.is_enabled = false

	priority.calculate_steering(_acceleration)
	
	_velocity = (
			(
					_velocity + Vector2(_acceleration.linear.x, _acceleration.linear.y)
			).clamped(agent.linear_speed_max)
	)
	_velocity = _velocity.linear_interpolate(Vector2.ZERO, drag_factor)
	
	_angular_velocity = clamp(
			_angular_velocity + _acceleration.angular,
			-agent.angular_speed_max,
			agent.angular_speed_max
	)
	_angular_velocity = lerp(_angular_velocity, 0, angular_drag_factor)
	
	_velocity = move_and_slide(_velocity)
	rotation += deg2rad(_angular_velocity) * delta


func _update_agent() -> void:
	agent.position.x = global_position.x
	agent.position.y = global_position.y
	agent.orientation = rotation
	agent.linear_velocity.x = _velocity.x
	agent.linear_velocity.y = _velocity.y
	agent.angular_velocity = _angular_velocity
