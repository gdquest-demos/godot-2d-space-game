class_name Projectile
extends KinematicBody2D


export var speed := 750.0
export var damage := 10

var direction := Vector2.ZERO
var shooter: Node

onready var lifespan_timer := $Lifespan


func _ready() -> void:
	direction = -GSAIUtils.angle_to_vector2(rotation)
	# warning-ignore:return_value_discarded
	lifespan_timer.connect("timeout", self, "_on_Lifespan_timeout")


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(direction * speed * delta)
	if collision:
		collision.collider.emit_signal("damaged", damage, shooter)
		queue_free()


func _on_Lifespan_timeout() -> void:
	queue_free()
