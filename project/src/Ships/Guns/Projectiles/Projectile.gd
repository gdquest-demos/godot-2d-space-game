# A physics body that moves in a straight line at a constant speed until it runs
# into something that it's able to collide with, at which point it signals
# damage.
class_name Projectile
extends KinematicBody2D

export var speed := 1650.0
export var damage := 10.0
export var distortion_emitter: PackedScene

var direction := Vector2.ZERO
var shooter: Node

onready var tween := $Tween
onready var sprite := $Sprite
onready var player := $AnimationPlayer
onready var remote_transform := $DistortionTransform
onready var visibility_notifier: VisibilityNotifier2D = $VisibilityNotifier2D


func _ready() -> void:
	direction = -GSAIUtils.angle_to_vector2(rotation)
	visibility_notifier.connect("screen_exited", self, "die")

	sprite.material = sprite.material.duplicate()
	player.play("Flicker")

	var emitter := distortion_emitter.instance()
	ObjectRegistry.register_distortion_effect(emitter)
	remote_transform.remote_path = emitter.get_path()


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(direction * speed * delta)
	if collision and not tween.is_active():
		Events.emit_signal("damaged", collision.collider, damage, shooter)
		queue_free()


func die() -> void:
	tween.interpolate_method(self, "_fade", 1, 0, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	queue_free()


func _fade(value: float) -> void:
	sprite.material.set_shader_param("fade_amount", value)
