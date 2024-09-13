# A state for the pirates' finite state machine. The squad leader sets a timer
# and emits a signal when it's time to go on patrol, and the squaddies follow
# based on the signal.
extends PirateState

var initialized := false

const REST_TIME_MIN := 15.0
const REST_TIME_MAX := 30.0

var _timer: Timer
var _accel := GSAITargetAcceleration.new()


func _ready() -> void:
	super()
	owner.squad_leader_changed.connect(_on_Leader_changed)


func enter(_msg := {}) -> void:
	if ship.is_squad_leader:
		if not _timer:
			_timer = Timer.new()
			add_child(_timer)
		_timer.timeout.connect(_on_Timer_timeout)
		_timer.start(ship.rng.randf_range(REST_TIME_MIN, REST_TIME_MAX))
	else:
		Events.begin_patrol.connect(_on_SquadLeader_begin_patrol)


func exit() -> void:
	if ship.is_squad_leader:
		if _timer:
			_timer.timeout.disconnect(_on_Timer_timeout)
	else:
		Events.begin_patrol.disconnect(_on_SquadLeader_begin_patrol)


func physics_process(delta: float) -> void:
	ship.agent._apply_steering(_accel, delta)


func _on_Timer_timeout() -> void:
	Events.begin_patrol.emit(ship)
	_state_machine.transition_to("Patrol", {patrol_point = ship.patrol_point})


func _on_SquadLeader_begin_patrol(leader: Node) -> void:
	if ship.squad_leader == leader:
		_state_machine.transition_to("Patrol", {patrol_point = ship.patrol_point})


func _on_Leader_changed(current_patrol_point: Vector2) -> void:
	if _state_machine.state == self:
		_state_machine.transition_to("Rest", {patrol_point = current_patrol_point})
