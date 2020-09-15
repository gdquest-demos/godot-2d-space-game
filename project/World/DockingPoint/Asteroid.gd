# Represents an extended dockable that holds a random amount of mineable
# resources.
class_name Asteroid
extends DockingPoint

signal mined(amount)
signal depleted

export var min_iron_amount := 5.0
export var max_iron_amount := 100.0
export var min_scale := 0.2

onready var anim_player := $AnimationPlayer
onready var fx_anim_player := $FXAnimationPlayer
onready var fx_tween := $FXTween
onready var sprite := $Sprite

var iron_amount: float


func setup(rng: RandomNumberGenerator) -> void:
	iron_amount = rng.randf_range(min_iron_amount, max_iron_amount)
	scale *= max(iron_amount / max_iron_amount, min_scale)


func mine_amount(value: float) -> float:
	var mined := min(iron_amount, value)
	iron_amount -= mined
	emit_signal("mined", mined)

	if is_equal_approx(iron_amount, 0.0):
		undock()
		shrink()
	elif not anim_player.is_playing():
		fx_anim_player.play("pulse")

	return mined


# Animates the asteroid shrinking down and frees it.
func shrink() -> void:
	if fx_anim_player.is_playing():
		fx_anim_player.stop(false)
	fx_tween.interpolate_property(
		sprite, "scale", sprite.scale, Vector2.ZERO, 0.25, Tween.TRANS_BACK, Tween.EASE_IN
	)
	fx_tween.interpolate_property(
		dock_aura, "scale", dock_aura.scale, Vector2.ZERO, 0.5, Tween.TRANS_BACK, Tween.EASE_IN
	)
	fx_tween.start()
	yield(fx_tween, "tween_all_completed")
	queue_free()


func _on_DockingArea_body_entered(body: Node) -> void:
	._on_DockingArea_body_entered(body)
	anim_player.stop(false)


func _on_DockingArea_body_exited(body: Node) -> void:
	._on_DockingArea_body_exited(body)
	anim_player.play()
