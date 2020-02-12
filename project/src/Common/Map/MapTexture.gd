extends TextureRect


onready var tween := $Tween


func _toggle_map(map_up: bool, tween_time: float) -> void:
	if map_up:
		visible = true
		tween.interpolate_property(
			self,
			"modulate",
			Color.transparent,
			Color.white,
			tween_time,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT
		)
	else:
		tween.interpolate_property(
			self,
			"modulate",
			Color.white,
			Color.transparent,
			tween_time,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT
		)
	tween.start()
	if not map_up:
		yield(tween, "tween_all_completed")
		visible = false
