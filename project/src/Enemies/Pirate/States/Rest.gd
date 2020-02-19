extends State

const REST_TIME_MIN := 2.0
const REST_TIME_MAX := 5.0

var _timer: Timer


func enter(_msg := {}) -> void:
	yield(owner, "initialized")
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


func _on_Timer_timeout() -> void:
	owner.emit_signal("begin_patrol", owner.patrol_point)
	_state_machine.transition_to("Patrol", {patrol_point = owner.patrol_point})


func _on_SquadLeader_begin_patrol(patrol_point: Vector2) -> void:
	_state_machine.transition_to("Patrol", {patrol_point = patrol_point})
