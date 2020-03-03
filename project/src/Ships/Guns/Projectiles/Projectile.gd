# A physics body that moves in a straight line at a constant speed until it runs
# into something that it's able to collide with, at which point it signals
# damage.
class_name Projectile
extends KinematicBody2D

export var speed := 750.0
export var damage := 10.0
export var distortion_emitter: PackedScene

var direction := Vector2.ZERO
var shooter: Node
var dead := false

onready var lifespan_timer := $Lifespan
onready var tween := $Tween
onready var sprite := $Sprite
onready var player := $AnimationPlayer
onready var remote_transform := $DistortionTransform


func _ready() -> void:
	direction = -GSAIUtils.angle_to_vector2(rotation)
	lifespan_timer.connect("timeout", self, "_on_Lifespan_timeout")
	
	sprite.material = sprite.material.duplicate()
	player.play("Flicker")
	
	var emitter := EmitterCache.get_new_emitter(distortion_emitter)
	ObjectRegistry.register_distortion_effect(emitter)
	remote_transform.remote_path = emitter.get_path()


func fade(value: float) -> void:
	sprite.material.set_shader_param("fade_amount", value)


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(direction * speed * delta)
	if not dead:
		if collision:
			Events.emit_signal("damaged", collision.collider, damage, shooter)
			queue_free()


func _on_Lifespan_timeout() -> void:
	dead = true
	
	tween.interpolate_method(self, "fade", 1, 0, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	
	queue_free()
