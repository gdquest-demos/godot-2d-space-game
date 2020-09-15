# Animates a circular area scaling up and down. See the `DockingPoint` and its `DockingAura` for an
# example.
class_name TweenAura
extends Tween

export var scale_hidden := Vector2.ZERO
export var scale_final := Vector2(1, 1)
export var duration_appear := 1.0
export var duration_disappear := 0.5


func make_appear(aura: Sprite) -> void:
	if is_active():
		return
	if aura.visible:
		return
	interpolate_property(
		aura, "scale", aura.scale, scale_final, duration_appear, Tween.TRANS_ELASTIC, Tween.EASE_OUT
	)
	aura.visible = true
	start()


func make_disappear(aura: Sprite) -> void:
	if is_active():
		return
	if not aura.visible:
		return
	interpolate_property(
		aura, "scale", aura.scale, scale_hidden, duration_disappear, Tween.TRANS_BACK, Tween.EASE_IN
	)
	start()
	yield(self, "tween_completed")
	aura.visible = false
