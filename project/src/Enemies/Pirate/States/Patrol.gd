extends State

const PATROL_TIME_MIN := 15.0
const PATROL_TIME_MAX := 45.0

export var patrol_radius := 500.0

var patrol_point := Vector2.ZERO
var acceleration := GSAITargetAcceleration.new()
var follow_path: GSAIFollowPath
var _timer: Timer

onready var path: GSAIPath
onready var priority := GSAIPriority.new(owner.agent, 10)


func _ready() -> void:
	yield(owner, "initialized")
	follow_path = GSAIFollowPath.new(owner.agent, path, 100, 0.3)
	var look := GSAILookWhereYouGo.new(owner.agent)
	look.alignment_tolerance = owner.ALIGNMENT_TOLERANCE
	look.deceleration_radius = owner.DECELERATION_RADIUS

	var path_blend := GSAIBlend.new(owner.agent)

	path_blend.add(follow_path, 1)
	path_blend.add(look, 1)

	var separation := GSAISeparation.new(owner.agent, owner.squad_proximity)
	separation.decay_coefficient = 2000

	var cohesion := GSAICohesion.new(owner.agent, owner.squad_proximity)
	var group_blend := GSAIBlend.new(owner.agent)

	group_blend.add(separation, 4.5)
	group_blend.add(cohesion, 0.5)

	var avoid_collisions := GSAIAvoidCollisions.new(owner.agent, owner.world_proximity)

	priority.add(avoid_collisions)

	var faction_avoid := GSAIAvoidCollisions.new(owner.agent, owner.all_pirates_proximity)
	priority.add(faction_avoid)

	priority.add(group_blend)
	priority.add(path_blend)

	if owner.is_squad_leader:
		_timer = Timer.new()
		add_child(_timer)


func enter(msg := {}) -> void:
	if not path:
		patrol_point = msg.patrol_point
		var patrol_corners := [
			Vector3(patrol_point.x, patrol_point.y - patrol_radius, 0),
			Vector3(patrol_point.x + patrol_radius, patrol_point.y, 0),
			Vector3(patrol_point.x, patrol_point.y + patrol_radius, 0),
			Vector3(patrol_point.x - patrol_radius, patrol_point.y, 0),
			Vector3(patrol_point.x, patrol_point.y - patrol_radius, 0)
		]
		path = GSAIPath.new(patrol_corners, true)
		follow_path.path = path
	if owner.is_squad_leader:
		#warning-ignore:return_value_discarded
		_timer.connect("timeout", self, "_on_Timer_timeout")
		_timer.start(owner.rng.randf_range(PATROL_TIME_MIN, PATROL_TIME_MAX))
	else:
		owner.squad_leader.connect("end_patrol", self, "_on_SquadLeader_end_patrol")


func exit() -> void:
	if owner.is_squad_leader:
		#warning-ignore:return_value_discarded
		_timer.disconnect("timeout", self, "_on_Timer_timeout")
	else:
		owner.squad_leader.disconnect("end_patrol", self, "_on_SquadLeader_end_patrol")


func physics_process(_delta: float) -> void:
	if not path:
		return

	priority.calculate_steering(acceleration)
	owner.agent._apply_steering(acceleration, _delta)


func _on_Timer_timeout() -> void:
	emit_signal("end_patrol")
	_state_machine.transition_to("Rest")


func _on_SquadLeader_end_patrol() -> void:
	_state_machine.transition_to("Rest")
