# State for the player's finite state machine. Controls approaching and
# attaching to dockable objects, and using steering behaviors to orient away
# from and back up to a dockable object an detecting when it touches it.
extends PlayerState

enum DockingProcess { CLEARING, DOCKING, DOCKED }

export var docking_release_speed := 150.0
export var docking_speed_multiplier := 0.65

var _acceleration := GSAITargetAcceleration.new()
var _agent: GSAISteeringAgent

var _reverse_face_position := GSAIAgentLocation.new()
var _dock_position := GSAISteeringAgent.new()

var _priority: GSAIPriority
var _flee_blend: GSAIBlend

var _docking_phase := 0

var _current_docking_point: Node2D
var _controls_disabled := false


func _ready() -> void:
	yield(owner, "ready")

	_agent = _parent.agent

	var seek := GSAISeek.new(_agent, _dock_position)

	# Flee makes sure we will have a minimum distance from the docking point to
	# prevent docking sideways
	var flee := GSAIFlee.new(_agent, _dock_position)
	# Face makes sure we face away from the docking point
	var face := GSAIFace.new(_agent, _reverse_face_position)
	face.alignment_tolerance = deg2rad(15)
	face.deceleration_radius = deg2rad(45)

	_flee_blend = GSAIBlend.new(_agent)
	_flee_blend.add(flee, 1)
	_flee_blend.add(face, 1)
	_flee_blend.is_enabled = false

	_priority = GSAIPriority.new(_agent)
	_priority.add(_flee_blend)
	_priority.add(seek)


func enter(msg := {}) -> void:
	var dock_position: Vector2 = msg.position_docking_partner
	var dock_radius: float = msg.radius_docking_partner

	_dock_position.position.x = dock_position.x
	_dock_position.position.y = dock_position.y
	_dock_position.bounding_radius = dock_radius

	_docking_phase = DockingProcess.CLEARING
	_flee_blend.is_enabled = true


func physics_process(delta: float) -> void:
	if _docking_phase == DockingProcess.DOCKED:
		return

	var current_position := _agent.position
	var dock_position := _dock_position.position

	var to_dock := GSAIUtils.to_vector2(current_position - dock_position).normalized()
	var facing_direction := GSAIUtils.angle_to_vector2(ship.rotation).normalized()

	var dot_face = to_dock.dot(facing_direction)

	var total_radius := _agent.bounding_radius + _dock_position.bounding_radius

	if dot_face <= -0.9 and current_position.distance_to(dock_position) > total_radius:
		_flee_blend.is_enabled = false
		_docking_phase = DockingProcess.DOCKING

	_reverse_face_position.position = (current_position + GSAIUtils.to_vector3(to_dock))

	_priority.calculate_steering(_acceleration)
	_parent.linear_velocity += GSAIUtils.to_vector2(
		_acceleration.linear * docking_speed_multiplier * delta
	)
	_parent.angular_velocity += _acceleration.angular * delta
	_parent.physics_process(delta)

	if _docking_phase == DockingProcess.DOCKING:
		var slide_count: int = ship.get_slide_count()

		for s in range(slide_count):
			var collision: KinematicCollision2D = ship.get_slide_collision(s)

			if collision.collider.collision_layer == 2:
				_docking_phase = DockingProcess.DOCKED
				_current_docking_point = collision.collider.owner
				Events.emit_signal("docked", _current_docking_point)
				_current_docking_point.set_docking_remote(ship, _agent.bounding_radius * 0.75)
				Events.connect("force_undock", self, "_on_Ship_force_undock")
				ship.vfx.create_ripple()
				ship.vfx.create_dust()
				return


func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_dock") and not _controls_disabled:
		if _docking_phase == DockingProcess.DOCKED:
			Events.emit_signal("undocked")
			Events.disconnect("force_undock", self, "_on_Ship_force_undock")

			var direction: Vector2 = (ship.global_position - Vector2(_dock_position.position.x, _dock_position.position.y)).normalized()

			_current_docking_point.undock()
			_parent.linear_velocity += direction * docking_release_speed

		_state_machine.transition_to("Move/Travel")


func _on_Ship_force_undock() -> void:
	Events.disconnect("force_undock", self, "_on_Ship_force_undock")
	_state_machine.transition_to("Move/Travel")
