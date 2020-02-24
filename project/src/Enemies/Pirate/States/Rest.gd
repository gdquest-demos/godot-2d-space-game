extends State

var initialized := false

const REST_TIME_MIN := 15.0
const REST_TIME_MAX := 30.0

var _timer: Timer
var _accel := GSAITargetAcceleration.new()


func _ready() -> void:
	owner.connect("squad_leader_changed", self, "_on_Leader_changed")


func enter(_msg := {}) -> void:
	if owner.is_squad_leader:
		if not _timer:
			_timer = Timer.new()
			add_child(_timer)
		_timer.connect("timeout", self, "_on_Timer_timeout")
		_timer.start(owner.rng.randf_range(REST_TIME_MIN, REST_TIME_MAX))
	else:
		Events.connect("begin_patrol", self, "_on_SquadLeader_begin_patrol")


func exit() -> void:
	if owner.is_squad_leader:
		if _timer:
			_timer.disconnect("timeout", self, "_on_Timer_timeout")
	else:
		Events.disconnect("begin_patrol", self, "_on_SquadLeader_begin_patrol")


func physics_process(delta: float) -> void:
	owner.agent._apply_steering(_accel, delta)


func _on_Timer_timeout() -> void:
	Events.emit_signal("begin_patrol", owner)
	_state_machine.transition_to("Patrol", {patrol_point = owner.patrol_point})


func _on_SquadLeader_begin_patrol(leader: Node) -> void:
	if owner.squad_leader == leader:
		_state_machine.transition_to("Patrol", {patrol_point = owner.patrol_point})


func _on_Leader_changed(current_patrol_point: Vector2) -> void:
	if _state_machine.state == self:
		_state_machine.transition_to("Rest", {patrol_point = current_patrol_point})
