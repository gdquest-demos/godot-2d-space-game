extends State

var initialized := false

const REST_TIME_MIN := 15.0
const REST_TIME_MAX := 30.0

var _timer: Timer
var _accel := GSAITargetAcceleration.new()


func enter(_msg := {}) -> void:
	if not initialized:
		yield(owner, "initialized")
		initialized = true
	
	if owner.is_squad_leader:
		if not _timer:
			_timer = Timer.new()
			add_child(_timer)
		#warning-ignore:return_value_discarded
		_timer.connect("timeout", self, "_on_Timer_timeout")
		_timer.start(owner.rng.randf_range(REST_TIME_MIN, REST_TIME_MAX))
	else:
		#warning-ignore:return_value_discarded
		owner.squad_leader.connect("begin_patrol", self, "_on_SquadLeader_begin_patrol")


func exit() -> void:
	if owner.is_squad_leader:
		_timer.disconnect("timeout", self, "_on_Timer_timeout")
	else:
		owner.squad_leader.disconnect("begin_patrol", self, "_on_SquadLeader_begin_patrol")


func physics_process(delta: float) -> void:
	owner.agent._apply_steering(_accel, delta)


func _on_Timer_timeout() -> void:
	owner.emit_signal("begin_patrol")
	_state_machine.transition_to("Patrol", {patrol_point = owner.patrol_point})


func _on_SquadLeader_begin_patrol() -> void:
	_state_machine.transition_to("Patrol")
