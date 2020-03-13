extends KinematicBody2D

export var speed_start := 1000.0
export var percentage_drag := 0.065
export var angular_velocity_start := PI / 6

var direction: Vector2
var velocity: Vector2
var angular_velocity := 0.0

onready var rng := RandomNumberGenerator.new()
onready var tween := $Tween
onready var burn := $ShrapnelBurn


func _ready() -> void:
	rng.randomize()

	direction = Vector2.UP.rotated(rng.randf_range(-PI, PI))
	velocity = direction * speed_start
	angular_velocity = angular_velocity_start * (rng.randf() * 2 - 1)
	burn.process_material = burn.process_material.duplicate()
	burn.process_material.scale *= rng.randf_range(0.5, 3)
	burn.emitting = true


func _physics_process(delta: float) -> void:
	move_and_slide(velocity)
	velocity = velocity.linear_interpolate(Vector2.ZERO, percentage_drag)
	rotation += angular_velocity * delta
	if not tween.is_active() and velocity.length_squared() < 5.0:
		tween.interpolate_property(
			self,
			"modulate",
			Color.white,
			Color.transparent,
			1.0,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT
		)
		tween.start()
		yield(tween, "tween_all_completed")
		queue_free()
