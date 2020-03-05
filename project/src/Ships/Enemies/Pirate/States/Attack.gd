# State for the pirates' finite state machine. Initializes and controls the way
# the pirate ships will chase and maintain a certain distance from the player,
# or when to break off pursuit and return to patrol, and when to fire the gun.
extends PirateState

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
	pursue = GSAIPursue.new(ship.agent, target)
	var avoid := GSAIAvoidCollisions.new(ship.agent, ship.world_proximity)
	var squad_avoid := GSAIAvoidCollisions.new(ship.agent, ship.squad_proximity)
	face = GSAIFace.new(ship.agent, target)

	target_separate = GSAIRadiusProximity.new(ship.agent, [], distance_from_player_min)

	var separate := GSAISeparation.new(ship.agent, target_separate)
	separate.decay_coefficient = 20000

	blend = GSAIBlend.new(ship.agent)
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

	if ship.is_squad_leader:
		starting_position = ship.global_position
	else:
		Events.connect("call_off_pursuit", self, "_on_Leader_call_off_pursuit")


func exit() -> void:
	if not ship.is_squad_leader:
		Events.disconnect("call_off_pursuit", self, "_on_Leader_call_off_pursuit")


func physics_process(delta: float) -> void:
	blend.calculate_steering(accel)
	ship.agent._apply_steering(accel, delta)
	var facing_direction := GSAIUtils.angle_to_vector2(ship.agent.orientation)
	var to_player := GSAIUtils.to_vector2(ship.agent.position - target.position).normalized()
	var player_dot_facing := facing_direction.dot(to_player)

	if player_dot_facing > 1 - firing_alignment_tolerance_percentage:
		ship.gun.fire(ship.gun.global_position, ship.agent.orientation, ship.projectile_mask)
	if ship.is_squad_leader:
		var distance_to := starting_position.distance_squared_to(ship.global_position)
		if distance_to > pursuit_distance_max * pursuit_distance_max:
			Events.emit_signal("call_off_pursuit", ship)
			_state_machine.transition_to("Patrol", {patrol_point = ship.patrol_point})


func _on_Leader_call_off_pursuit(leader: Node) -> void:
	if leader == ship.squad_leader:
		_state_machine.transition_to("Patrol", {patrol_point = ship.patrol_point})
