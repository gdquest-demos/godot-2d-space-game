# Blends multiple steering behaviors into one, and returns a weighted
# acceleration from their calculations.
#
# Stores the behaviors internally as dictionaries of the form
# {
# 	behavior : GSTSteeringBehavior,
# 	weight : float
# }
class_name GSTBlend
extends GSTSteeringBehavior


var _behaviors := []
var _acceleration := GSTTargetAcceleration.new()


func _init(agent: GSTSteeringAgent).(agent) -> void:
	pass


# Appends a behavior to the internal array along with its `weight`.
func add(behavior: GSTSteeringBehavior, weight: float) -> void:
	behavior.agent = agent
	_behaviors.append({behavior = behavior, weight = weight})


# Returns the behavior at the specified `index`, or an empty `Dictionary` if
# none was found.
func get_behavior_at(index: int) -> Dictionary:
	if _behaviors.size() > index:
		return _behaviors[index]
	printerr("Tried to get index " + str(index) + " in array of size " + str(_behaviors.size()))
	return {}


func _calculate_steering(blended_acceleration: GSTTargetAcceleration) -> GSTTargetAcceleration:
	blended_acceleration.set_zero()

	for i in range(_behaviors.size()):
		var bw: Dictionary = _behaviors[i]
		bw.behavior.calculate_steering(_acceleration)

		blended_acceleration.add_scaled_accel(_acceleration, bw.weight)

	blended_acceleration.linear = GSTUtils.clampedv3(blended_acceleration.linear, agent.linear_acceleration_max)
	blended_acceleration.angular = clamp(
			blended_acceleration.angular,
			-agent.angular_acceleration_max,
			agent.angular_acceleration_max
	)

	return blended_acceleration
