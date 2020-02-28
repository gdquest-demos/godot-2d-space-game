# State for the pirate's finite state machine. Builds a rounded diamond shaped
# path for them to patrol around a cluster of asteroids or given point in space.
# 
# The squad leader will use the path following steering behavior, while the
# squaddies will follow the leader using cohesion and separation.
extends State

const PATROL_TIME_MIN := 15.0
const PATROL_TIME_MAX := 30.0

export var patrol_radius := 500.0

var patrol_point := Vector2.ZERO
var acceleration := GSAITargetAcceleration.new()
var follow_path: GSAIFollowPath
var pursue: GSAIPursue
var initialized := false
var _timer: Timer

onready var path: GSAIPath
onready var priority: GSAIPriority


func _ready() -> void:
	yield(owner, "ready")
	set_behaviors()
	owner.connect("squad_leader_changed", self, "_on_Leader_changed")


func enter(msg := {}) -> void:
	if owner.is_squad_leader:
		patrol_point = msg.patrol_point
		var patrol_corners := [
			Vector3(patrol_point.x, patrol_point.y - patrol_radius, 0),
			Vector3(patrol_point.x + patrol_radius, patrol_point.y, 0),
			Vector3(patrol_point.x, patrol_point.y + patrol_radius, 0),
			Vector3(patrol_point.x - patrol_radius, patrol_point.y, 0)
		]

		var patrol_points := [
			patrol_corners[0] + Vector3(-patrol_radius / 4, 0, 0),
			patrol_corners[0] + Vector3(patrol_radius / 4, 0, 0),
			patrol_corners[1] + Vector3(0, -patrol_radius / 4, 0),
			patrol_corners[1] + Vector3(0, patrol_radius / 4, 0),
			patrol_corners[2] + Vector3(patrol_radius / 4, 0, 0),
			patrol_corners[2] + Vector3(-patrol_radius / 4, 0, 0),
			patrol_corners[3] + Vector3(0, patrol_radius / 4, 0),
			patrol_corners[3] + Vector3(0, -patrol_radius / 4, 0)
		]

		if owner.rng.randf() > 0.5:
			patrol_points.invert()

		if not path:
			path = GSAIPath.new(patrol_points, false)
			follow_path.path = path
		else:
			path.create_path(patrol_points)

		_timer.connect("timeout", self, "_on_Timer_timeout")
		_timer.start(owner.rng.randf_range(PATROL_TIME_MIN, PATROL_TIME_MAX))
	else:
		Events.connect("end_patrol", self, "_on_SquadLeader_end_patrol")


func exit() -> void:
	if owner.is_squad_leader:
		if _timer:
			_timer.disconnect("timeout", self, "_on_Timer_timeout")
	else:
		Events.disconnect("end_patrol", self, "_on_SquadLeader_end_patrol")


func physics_process(_delta: float) -> void:
	priority.calculate_steering(acceleration)
	owner.agent._apply_steering(acceleration, _delta)


func set_behaviors() -> void:
	priority = GSAIPriority.new(owner.agent)
	var avoid_collisions := GSAIAvoidCollisions.new(owner.agent, owner.world_proximity)
	priority.add(avoid_collisions)

	var faction_avoid := GSAIAvoidCollisions.new(owner.agent, owner.faction_proximity)
	priority.add(faction_avoid)

	var look := GSAILookWhereYouGo.new(owner.agent)
	look.alignment_tolerance = owner.ALIGNMENT_TOLERANCE
	look.deceleration_radius = owner.DECELERATION_RADIUS

	if owner.is_squad_leader:
		follow_path = GSAIFollowPath.new(owner.agent, path, 100, 0.3)

		var path_blend := GSAIBlend.new(owner.agent)

		path_blend.add(follow_path, 1)
		path_blend.add(look, 1)

		priority.add(path_blend)
		_timer = Timer.new()
		add_child(_timer)
	else:
		var separation := GSAISeparation.new(owner.agent, owner.squad_proximity)
		separation.decay_coefficient = 2000

		var cohesion := GSAICohesion.new(owner.agent, owner.squad_proximity)

		pursue = GSAIPursue.new(owner.agent, owner.squad_leader.agent)

		var group_blend := GSAIBlend.new(owner.agent)
		group_blend.add(pursue, 0.65)
		group_blend.add(separation, 4.5)
		group_blend.add(cohesion, 0.3)
		group_blend.add(look, 1)

		priority.add(group_blend)


func _on_Timer_timeout() -> void:
	Events.emit_signal("end_patrol", owner)
	_state_machine.transition_to("Rest")


func _on_SquadLeader_end_patrol(leader: Node) -> void:
	if owner.squad_leader == leader:
		_state_machine.transition_to("Rest")


func _on_Leader_changed(current_patrol_point: Vector2) -> void:
	set_behaviors()
	if _state_machine.state == self:
		_state_machine.transition_to("Patrol", {patrol_point = current_patrol_point})
