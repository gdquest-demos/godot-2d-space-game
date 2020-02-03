extends State


export var acceleration_max := 15.0
export var linear_speed_max := 350.0
export var drag_linear_coeff := 0.05
export var reverse_multiplier := 0.25

export var angular_speed_max := 120
export var angular_acceleration_max := 45
export var drag_angular_coeff := 0.1

var linear_velocity := Vector2.ZERO
var angular_velocity := 0.0
var is_reversing := false
var can_fire := true

onready var agent := GSTSteeringAgent.new()
onready var gun: Node2D = owner.get_node("Gun")


func _ready() -> void:
	yield(owner, "ready")
	agent.linear_acceleration_max = acceleration_max * reverse_multiplier
	agent.linear_speed_max = linear_speed_max
	agent.angular_acceleration_max = angular_acceleration_max
	agent.angular_speed_max = angular_speed_max
	agent.bounding_radius = MathUtils.get_triangle_circumcircle_radius(owner.shape.polygon)
	_update_agent()


func physics_process(delta: float) -> void:
	_update_agent()
	
	linear_velocity = linear_velocity.clamped(linear_speed_max)
	linear_velocity = linear_velocity.linear_interpolate(Vector2.ZERO, drag_linear_coeff)
	
	angular_velocity = clamp(angular_velocity, -angular_speed_max, angular_speed_max)
	angular_velocity = lerp(angular_velocity, 0, drag_angular_coeff)
	
	linear_velocity = owner.move_and_slide(linear_velocity)
	owner.rotation += deg2rad(angular_velocity) * delta
	
	if can_fire and Input.is_action_pressed("fire"):
		gun.fire(gun.global_position, owner.rotation, owner.projectile_mask)


# TODO: Replace find_node with actual detection
func unhandled_input(event: InputEvent) -> void:
	if event.get_action_strength("toggle_dock") == 1 and owner.can_dock:
		_state_machine.transition_to("Move/Dock", 
				{
						position_docking_partner = get_tree().root.find_node(
								"DockingPoint", true, false
						).global_position,
						radius_docking_partner = get_tree().root.find_node(
								"DockingPoint", true, false
						).radius 
				}
		)
	elif (
			event.is_action_pressed("precision_mode") 
			or event.is_action_pressed("precision_mode_toggle")
	):
		_state_machine.transition_to(
				"Move/Precision",
				{ toggled = event.is_action_pressed("precision_mode_toggle") }
		)


func _update_agent() -> void:
	agent.position.x = owner.global_position.x
	agent.position.y = owner.global_position.y
	agent.orientation = owner.rotation
	agent.linear_velocity.x = linear_velocity.x
	agent.linear_velocity.y = linear_velocity.y
	agent.angular_velocity = angular_velocity
