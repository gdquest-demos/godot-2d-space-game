extends Particles2D


onready var timer := $Timer
var dying := false

func _ready() -> void:
	emitting = true


func _process(_delta: float) -> void:
	if not emitting and not dying:
		die()


func die() -> void:
	dying = true
	timer.start(lifetime)
	yield(timer, "timeout")
	queue_free()
