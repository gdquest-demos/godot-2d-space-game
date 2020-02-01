extends KinematicBody2D


export var linear_speed_max := 200.0
export var linear_accel_max := 15.0
export var linear_drag_coeff := 0.04
export var angular_speed_max := 270
export var angular_accel_max := 15
export var angular_drag_coeff := 0.1
export var distance_from_player_min := 200.0
export var distance_from_obstacles_min := 200.0

var _accel := GSTTargetAcceleration.new()
var _linear_velocity := Vector2.ZERO
var _angular_velocity := 0.0

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


func _ready() -> void:
	agent.linear_acceleration_max = linear_accel_max
	agent.linear_speed_max = linear_speed_max
	agent.angular_acceleration_max = angular_accel_max
	agent.angular_speed_max = angular_speed_max
	agent.bounding_radius = Utils.get_triangle_circumcircle_radius($CollisionShape.polygon)
	_update_agent()
	
	var pursue := GSTPursue.new(agent, player_agent)
	
	var face := GSTFace.new(agent, player_agent)
	face.alignment_tolerance = deg2rad(5)
	face.deceleration_radius = deg2rad(45)
	
	var pursue_face_blend := GSTBlend.new(agent)
	pursue_face_blend.add(pursue, 1)
	pursue_face_blend.add(face, 1)
	
	var separation := GSTSeparation.new(agent, player_proximity)
	separation.decay_coefficient = pow(player_proximity.radius, 2)/0.15
	
	pursue_face_blend.add(separation, 2)
	
	var avoid := GSTAvoidCollisions.new(agent, world_proximity)
	
	priority.add(avoid)
	priority.add(pursue_face_blend)
	
	var world_objects := get_tree().get_nodes_in_group("World_Objects")
	for wo in world_objects:
		var object_agent: GSTAgentLocation = wo.agent_location
		if object_agent:
			world_proximity.agents.append(object_agent)


func _physics_process(delta: float) -> void:
	_update_agent()
	
	priority.calculate_steering(_accel)
	
	_linear_velocity = (
			(
					_linear_velocity + Vector2(_accel.linear.x, _accel.linear.y)
			).clamped(agent.linear_speed_max)
	)
	_linear_velocity = _linear_velocity.linear_interpolate(Vector2.ZERO, linear_drag_coeff)
	
	_angular_velocity = clamp(
			_angular_velocity + _accel.angular,
			-agent.angular_speed_max,
			agent.angular_speed_max
	)
	_angular_velocity = lerp(_angular_velocity, 0, angular_drag_coeff)
	
	_linear_velocity = move_and_slide(_linear_velocity)
	rotation += deg2rad(_angular_velocity) * delta


func _update_agent() -> void:
	agent.position.x = global_position.x
	agent.position.y = global_position.y
	agent.orientation = rotation
	agent.linear_velocity.x = _linear_velocity.x
	agent.linear_velocity.y = _linear_velocity.y
	agent.angular_velocity = _angular_velocity
