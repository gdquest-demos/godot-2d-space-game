class_name Projectile
extends KinematicBody2D


export var speed := 750.0
export var damage := 10

var direction := Vector2.ZERO

onready var lifespan_timer := $Lifespan


func _ready() -> void:
	direction = -GSTUtils.angle_to_vector2(rotation)
	lifespan_timer.connect("timeout", self, "_on_Lifespan_timeout")


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(direction * speed * delta)
	if collision:
		collision.collider.emit_signal("damaged", damage)
		queue_free()


func _on_Lifespan_timeout() -> void:
	queue_free()
