extends State


export var docking_release_speed := 150.0

var _acceleration := GSTTargetAcceleration.new()
var _agent: GSTSteeringAgent

var _reverse_face_position := GSTAgentLocation.new()
var _dock_position := GSTSteeringAgent.new()

var _priority: GSTPriority
var _flee_blend: GSTBlend

var _is_docked := false
var _is_on_final_approach := false

onready var previous_parent: = owner.get_parent()


func _ready() -> void:
	yield(owner, "ready")
	
	_agent = _parent.agent
	
	var face := GSTFace.new(_parent.agent, _reverse_face_position)
	face.alignment_tolerance = deg2rad(15)
	face.deceleration_radius = deg2rad(45)
	
	var seek := GSTSeek.new(_parent.agent, _dock_position)
	
	# Flee will be used to ensure a minimum distance from the docking point to
	# prevent docking sideways
	var flee := GSTFlee.new(_parent.agent, _dock_position)
	var look := GSTLookWhereYouGo.new(_parent.agent)
	look.alignment_tolerance = deg2rad(15)
	look.deceleration_radius = deg2rad(45)
	
	_flee_blend = GSTBlend.new(_parent.agent)
	_flee_blend.add(flee, 1)
	_flee_blend.add(look, 1)
	_flee_blend.is_enabled = false
	
	_priority = GSTPriority.new(_parent.agent)
	_priority.add(_flee_blend)
	_priority.add(face)
	_priority.add(seek)


func enter(msg := {}) -> void:
	var dock_position: Vector2 = msg.position_docking_partner
	var dock_radius: float = msg.radius_docking_partner
	
	_dock_position.position.x = dock_position.x
	_dock_position.position.y = dock_position.y
	_dock_position.bounding_radius = dock_radius


func exit() -> void:
	_is_on_final_approach = false
	


func physics_process(delta: float) -> void:
	if _is_docked:
		return
	
	var current_position := _agent.position
	var dock_position := _dock_position.position
	var total_radius := _agent.bounding_radius+_dock_position.bounding_radius
	
	_flee_blend.is_enabled = (
			current_position.distance_to(dock_position) < total_radius and
			not _is_on_final_approach
	)
	
	_is_on_final_approach = not _flee_blend.is_enabled
	
	var reverse_face := current_position + (current_position - dock_position).normalized()
	
	_reverse_face_position.position = reverse_face
	
	_priority.calculate_steering(_acceleration)
	_parent.linear_velocity.x += _acceleration.linear.x
	_parent.linear_velocity.y += _acceleration.linear.y
	_parent.angular_velocity += _acceleration.angular
	_parent.physics_process(delta)
	
	if _is_on_final_approach:
		var slide_count: int = owner.get_slide_count()
		for s in range(slide_count):
			var collision: KinematicCollision2D = owner.get_slide_collision(s)
			if collision.collider.collision_layer == 2:
				_is_docked = true
				collision.collider.add_child(owner)


func unhandled_input(event: InputEvent) -> void:
	if event.get_action_strength("toggle_dock") == 1:
		if _is_docked:
			_is_docked = false
			
			var direction: Vector2 = (
					owner.global_position - 
					Vector2(
							_dock_position.position.x, _dock_position.position.y)
			).normalized()
			
			previous_parent.add_child(owner)
			
			_parent.linear_velocity += direction * docking_release_speed
		
		_state_machine.transition_to("Move/Travel")
