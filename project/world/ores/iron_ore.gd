extends Sprite2D

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer


func _init() -> void:
	visible = false


func animate_to(target_position: Vector2) -> void:
	var random_delay := randf() * 0.1
	var midpoint := _calculate_mid_point(target_position)

	var tween = create_tween()
	tween.tween_property(
		self, "scale", scale, 0.1
	).from(Vector2.ZERO).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(random_delay)
	tween.tween_property(
		self,
		"global_position",
		midpoint,
		0.4
	).from_current().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC).set_delay(random_delay)
	tween.tween_property(
		self,
		"global_position",
		target_position,
		0.6
	).from(midpoint).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(random_delay)
	scale = Vector2.ZERO
	visible = true
	tween.tween_property(
		self,
		"scale",
		Vector2.ZERO,
		0.25
	).from_current().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	audio.play()
	await tween.finished
	queue_free()


func _calculate_mid_point(target_position: Vector2) -> Vector2:
	var to_target := target_position - global_position
	var midpoint := global_position.lerp(target_position, 0.4)
	var direction_offset := to_target.normalized().rotated(PI / 2)
	var _offset := direction_offset * (randf_range(-1.0, 1.0) * 60.0 + 10.0)
	return midpoint + _offset
