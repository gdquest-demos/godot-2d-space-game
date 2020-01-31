extends State


export var linear_accel_max := 15.0
export var linear_speed_max := 350.0
export var drag_linear_coeff := 0.05
export var reverse_multiplier := 0.25

export var angular_speed_max := 120
export var angular_accel_max := 45
export var drag_angular_coeff := 0.1

var linear_velocity := Vector2.ZERO
var angular_velocity := 0.0
var reversing := false


func physics_process(delta: float) -> void:
	linear_velocity = linear_velocity.clamped(linear_speed_max)
	linear_velocity = linear_velocity.linear_interpolate(Vector2.ZERO, drag_linear_coeff)
	
	angular_velocity = clamp(angular_velocity, -angular_speed_max, angular_speed_max)
	angular_velocity = lerp(angular_velocity, 0, drag_angular_coeff)
	
	linear_velocity = owner.move_and_slide(linear_velocity)
	owner.rotation += deg2rad(angular_velocity) * delta
