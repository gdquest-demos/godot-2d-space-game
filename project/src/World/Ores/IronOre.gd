extends Sprite

onready var tween := $Tween
var target_position := Vector2.ZERO


func animate() -> void:
	tween.interpolate_property(
		self,
		"global_position",
		global_position,
		target_position,
		1,
		Tween.TRANS_BACK,
		Tween.EASE_OUT
	)
	tween.start()
	yield(tween, "tween_completed")
	tween.interpolate_property(
		self, "scale", scale, Vector2.ZERO, 0.25, Tween.TRANS_BACK, Tween.EASE_IN
	)
	tween.start()
	yield(tween, "tween_completed")
	queue_free()
