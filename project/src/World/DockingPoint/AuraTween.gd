extends Tween

export var hidden_scale := Vector2.ZERO
export var final_scale := Vector2(2, 2)
export var tween_out_duration := 1.0
export var tween_in_duration := 0.5

func tween_aura_out(aura: Sprite) -> void:
	if is_active():
		return
	if aura.visible:
		return
	interpolate_property(
		aura,
		"scale", 
		hidden_scale,
		final_scale,
		tween_out_duration,
		Tween.TRANS_ELASTIC,
		Tween.EASE_OUT)
	aura.visible = true
	start()


func tween_aura_in(aura: Sprite) -> void:
	if is_active():
		return
	if not aura.visible:
		return
	interpolate_property(
		aura,
		"scale", 
		final_scale,
		hidden_scale,
		tween_in_duration,
		Tween.TRANS_BACK,
		Tween.EASE_IN)
	start()
	yield(self, "tween_completed")
	aura.visible = false
