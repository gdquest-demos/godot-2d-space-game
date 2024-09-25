# A physics body that moves in a straight line at a constant speed until it runs
# into something that it's able to collide with, at which point it signals
# damage.
class_name Projectile
extends CharacterBody2D

const _AUDIO_SAMPLES = [
	preload("weapons_plasma_shot_01.wav"),
	preload("weapons_plasma_shot_02.wav"),
	preload("weapons_plasma_shot_03.wav"),
	preload("weapons_plasma_shot_04.wav"),
	preload("weapons_plasma_shot_05.wav"),
	preload("weapons_plasma_shot_06.wav"),
]

@export var speed := 1650.0
@export var damage := 10.0
@export var distortion_emitter: PackedScene

var is_active := true: set = set_is_active
var direction := Vector2.ZERO
var shooter: Node

@onready var tween : Tween
@onready var sprite := $Sprite2D
@onready var player := $AnimationPlayer
@onready var remote_transform := $DistortionTransform
@onready var visibility_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	direction = -GSAIUtils.angle_to_vector2(rotation)
	visibility_notifier.screen_exited.connect(queue_free)

	sprite.material = sprite.material.duplicate()
	player.play("Flicker")

	var emitter := distortion_emitter.instantiate()
	ObjectRegistry.register_distortion_effect(emitter)
	remote_transform.remote_path = emitter.get_path()

	appear()

#E 0:01:17:0974   Projectile.gd:50 @ _physics_process(): Error calling from signal 'damaged' to callable: 'CharacterBody2D(PirateShip.gd)::_on_self_damaged': Cannot convert argument 3 from Object to Object.

func _physics_process(delta: float) -> void:
	var collision := move_and_collide(direction * speed * delta)
	if collision:
		Events.damaged.emit(collision.get_collider(), damage, shooter)
		die()


func appear() -> void:
	self.is_active = true
	tween = create_tween()
	tween.tween_method(_fade, 0.0, 1.0, 0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(
		self, "scale", scale, 0.05
	).from(scale / 5.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.play()

	audio.stream = _AUDIO_SAMPLES[randi() % _AUDIO_SAMPLES.size()]
	audio.play()


func die() -> void:
	self.is_active = false
	tween = create_tween()
	tween.tween_method(_fade, 1.0, 0.0, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.play()
	await tween.finished
	queue_free()


func set_is_active(value: bool) -> void:
	is_active = value
	collider.disabled = not is_active
	set_physics_process(is_active)


func _fade(value: float) -> void:
	sprite.material.set_shader_parameter("fade_amount", value)
