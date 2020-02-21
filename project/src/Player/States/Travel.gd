extends State


var reversing := false


func physics_process(delta: float) -> void:
	var movement := get_movement()
	reversing = movement.y > 0
	var direction := GSAIUtils.angle_to_vector2(_parent.agent.orientation)
	
	_parent.linear_velocity += (
			movement.y *
			direction *
			_parent.acceleration_max * (_parent.reverse_multiplier if reversing else 1)
	)
	_parent.angular_velocity += movement.x * _parent.agent.angular_acceleration_max
	
	_parent.physics_process(delta)


func get_movement() -> Vector2:
	return Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("thrust_back") - Input.get_action_strength("thrust_forwards")
	)


func unhandled_input(event: InputEvent) -> void:
	_parent.unhandled_input(event)
