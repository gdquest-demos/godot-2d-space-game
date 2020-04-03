extends Sprite

onready var tween := $Tween


func _init() -> void:
	visible = false


func animate_to(target_position: Vector2) -> void:
	var random_delay := randf() * 0.1
	var midpoint := _calculate_mid_point(target_position)

	tween.interpolate_property(
		self, "scale", Vector2.ZERO, scale, 0.1, Tween.TRANS_QUAD, Tween.EASE_OUT, random_delay
	)
	tween.interpolate_property(
		self,
		"global_position",
		global_position,
		midpoint,
		0.4,
		Tween.TRANS_CIRC,
		Tween.EASE_IN,
		random_delay
	)
	tween.interpolate_property(
		self,
		"global_position",
		midpoint,
		target_position,
		0.6,
		Tween.TRANS_BACK,
		Tween.EASE_OUT,
		0.4 + random_delay
	)
	tween.interpolate_property(
		self,
		"scale",
		scale,
		Vector2.ZERO,
		0.25,
		Tween.TRANS_BACK,
		Tween.EASE_IN,
		0.85 + random_delay
	)
	tween.start()
	scale = Vector2.ZERO
	yield(get_tree().create_timer(random_delay), "timeout")
	visible = true
	yield(tween, "tween_all_completed")
	queue_free()


func _calculate_mid_point(target_position: Vector2) -> Vector2:
	var to_target := target_position - global_position
	var midpoint := global_position.linear_interpolate(target_position, 0.4)
	var direction_offset := to_target.normalized().rotated(PI / 2)
	var offset := direction_offset * (rand_range(-1.0, 1.0) * 60.0 + 10.0)
	return midpoint + offset
