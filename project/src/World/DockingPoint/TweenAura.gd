# Animates a circular area scaling up and down. See the `DockingPoint` and its `DockingAura` for an
# example.
class_name TweenAura
extends Tween

export var hidden_scale := Vector2.ZERO
export var final_scale := Vector2(1, 1)
export var tween_out_duration := 1.0
export var tween_in_duration := 0.5


func make_appear(aura: Sprite) -> void:
	if is_active():
		return
	if aura.visible:
		return
	interpolate_property(
		aura,
		"scale",
		aura.scale,
		final_scale,
		tween_out_duration,
		Tween.TRANS_ELASTIC,
		Tween.EASE_OUT
	)
	aura.visible = true
	start()


func make_disappear(aura: Sprite) -> void:
	if is_active():
		return
	if not aura.visible:
		return
	interpolate_property(
		aura, "scale", aura.scale, hidden_scale, tween_in_duration, Tween.TRANS_BACK, Tween.EASE_IN
	)
	start()
	yield(self, "tween_completed")
	aura.visible = false
