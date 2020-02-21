extends State


const ARRIVAL_TOLERANCE := 350*350

var _initialized := false

onready var priority := GSAIPriority.new(owner.agent)
onready var patrol_target := GSAIAgentLocation.new()
onready var acceleration := GSAITargetAcceleration.new()


func _ready() -> void:
	if not _initialized:
		yield(owner, "initialized")
		_initialized = true
	
	owner.connect("leader_changed", self, "_on_Leader_changed")
	set_behaviors()


func enter(_msg := {}) -> void:
	yield(owner, "initialized")
	if not owner.is_squad_leader:
		owner.squad_leader.connect("reached_cluster", self, "_on_Leader_reached_cluster")
	else:
		var timer := Timer.new()
		add_child(timer)
		#warning-ignore:return_value_discarded
		timer.connect("timeout", self, "_on_Timer_timeout")
		timer.start(30)


func exit() -> void:
	queue_free()


func physics_process(delta: float) -> void:
	if owner.is_squad_leader:
		var distance_to := (
			patrol_target.position.distance_squared_to(
				GSAIUtils.to_vector3(owner.global_position)
			)
		)
		if distance_to <= ARRIVAL_TOLERANCE:
			owner.emit_signal("reached_cluster")
			_state_machine.transition_to("Rest")
	
	priority.calculate_steering(acceleration)
	owner.agent._apply_steering(acceleration, delta)


func set_behaviors() -> void:
	var avoid_collisions := GSAIAvoidCollisions.new(owner.agent, owner.world_proximity)
	priority.add(avoid_collisions)
	
	var faction_avoid := GSAIAvoidCollisions.new(owner.agent, owner.faction_proximity)
	priority.add(faction_avoid)
	
	var look := GSAILookWhereYouGo.new(owner.agent)
	look.alignment_tolerance = owner.ALIGNMENT_TOLERANCE
	look.deceleration_radius = owner.DECELERATION_RADIUS
	
	if owner.is_squad_leader:
		var arrive := GSAIArrive.new(owner.agent, patrol_target)
		arrive.deceleration_radius = 200
		arrive.arrival_tolerance = 50
		patrol_target.position = GSAIUtils.to_vector3(owner.patrol_point)
		
		var arrive_blend := GSAIBlend.new(owner.agent)
	
		arrive_blend.add(arrive, 1)
		arrive_blend.add(look, 1)
	
		priority.add(arrive_blend)
	else:
		var separation = GSAISeparation.new(owner.agent, owner.squad_proximity)
		separation.decay_coefficient = 2000
		
		var cohesion = GSAICohesion.new(owner.agent, owner.squad_proximity)
		
		var pursue = GSAIPursue.new(owner.agent, owner.squad_leader.agent)
		
		var group_blend = GSAIBlend.new(owner.agent)
		group_blend.add(pursue, 0.65)
		group_blend.add(separation, 4.5)
		group_blend.add(cohesion, 0.3)
		group_blend.add(look, 1)
		
		priority.add(group_blend)


func _on_Leader_reached_cluster() -> void:
	_state_machine.transition_to("Rest")


func _on_Timer_timeout() -> void:
	owner.emit_signal("reached_cluster")
	_state_machine.transition_to("Rest")


func _on_Leader_changed(
		old_leader: KinematicBody2D,
		new_leader: KinematicBody2D,
		current_patrol_point: Vector2
	) -> void:
	set_behaviors()
	_state_machine.transition_to("Spawn")
