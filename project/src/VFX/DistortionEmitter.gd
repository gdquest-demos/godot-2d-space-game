# One-shot particle emitter that recycles itself after use.
extends Particles2D

onready var timer := $Timer
var is_dying := false


func _ready() -> void:
	one_shot = true
	emitting = true


func _process(_delta: float) -> void:
	if not emitting and not is_dying:
		die()


func die() -> void:
	is_dying = true
	timer.start(lifetime)
	yield(timer, "timeout")
	queue_free()
