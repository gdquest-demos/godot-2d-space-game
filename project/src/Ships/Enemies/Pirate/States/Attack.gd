# State for the pirates' finite state machine. Initializes and controls the way
# the pirate ships will chase and maintain a certain distance from the player,
# or when to break off pursuit and return to patrol, and when to fire the gun.
extends State

export var distance_from_player_min := 200.0
export var firing_alignment_tolerance_percentage := 0.15
export var pursuit_distance_max := 800.0

var target: GSAISteeringAgent
var pursue: GSAIPursue
var blend: GSAIBlend
var face: GSAIFace
var accel := GSAITargetAcceleration.new()
var starting_position: Vector2
var target_separate: GSAIRadiusProximity


func _ready() -> void:
	yield(owner, "ready")
	pursue = GSAIPursue.new(owner.agent, target)
	var avoid := GSAIAvoidCollisions.new(owner.agent, owner.world_proximity)
	var squad_avoid := GSAIAvoidCollisions.new(owner.agent, owner.squad_proximity)
	face = GSAIFace.new(owner.agent, target)

	target_separate = GSAIRadiusProximity.new(owner.agent, [], distance_from_player_min)

	var separate := GSAISeparation.new(owner.agent, target_separate)
	separate.decay_coefficient = 20000

	blend = GSAIBlend.new(owner.agent)
	blend.add(avoid, 2)
	blend.add(squad_avoid, 1)
	blend.add(pursue, 1)
	blend.add(face, 1)
	blend.add(separate, 8)


func enter(msg := {}) -> void:
	target = msg.target.agent
	pursue.target = target
	face.target = target
	if not target_separate.agents.has(target):
		target_separate.agents.append(target)

	if owner.is_squad_leader:
		starting_position = owner.global_position
	else:
		Events.connect("call_off_pursuit", self, "_on_Leader_call_off_pursuit")


func exit() -> void:
	if not owner.is_squad_leader:
		Events.disconnect("call_off_pursuit", self, "_on_Leader_call_off_pursuit")


func physics_process(delta: float) -> void:
	blend.calculate_steering(accel)
	owner.agent._apply_steering(accel, delta)
	var facing_direction := GSAIUtils.angle_to_vector2(owner.agent.orientation)
	var to_player := GSAIUtils.to_vector2(owner.agent.position - target.position).normalized()
	var player_dot_facing := facing_direction.dot(to_player)

	if player_dot_facing > 1 - firing_alignment_tolerance_percentage:
		owner.gun.fire(owner.gun.global_position, owner.agent.orientation, owner.projectile_mask)
	if owner.is_squad_leader:
		var distance_to := starting_position.distance_squared_to(owner.global_position)
		if distance_to > pursuit_distance_max * pursuit_distance_max:
			Events.emit_signal("call_off_pursuit", owner)
			_state_machine.transition_to("Patrol", {patrol_point = owner.patrol_point})


func _on_Leader_call_off_pursuit(leader: Node) -> void:
	if leader == owner.squad_leader:
		_state_machine.transition_to("Patrol", {patrol_point = owner.patrol_point})
