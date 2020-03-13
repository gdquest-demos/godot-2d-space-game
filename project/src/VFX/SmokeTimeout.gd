extends Particles2D

var timing_out := false


func _process(delta: float) -> void:
	if not timing_out and not emitting:
		timing_out = true
		var timer := get_tree().create_timer(5)
		yield(timer, "timeout")
		owner.terminate()
