# Represents an extended dockable that holds a random amount of mineable
# resources.
class_name Asteroid
extends DockingPoint

export var min_iron_amount := 5.0
export var max_iron_amount := 100.0

onready var anim_player := $AnimationPlayer
onready var fx_anim_player := $FXAnimationPlayer
onready var fx_tween := $FXTween
onready var sprite := $Sprite

var iron_amount: float
var world: Node2D


func setup(rng: RandomNumberGenerator, _world: Node2D) -> void:
	world = _world
	iron_amount = rng.randf_range(min_iron_amount, max_iron_amount)
	scale *= iron_amount / max_iron_amount


func mine_amount(value: float) -> float:
	var mined := value
	if iron_amount - mined < 0:
		mined = iron_amount
	world.remove_iron(mined, self)
	iron_amount = iron_amount - mined
	if not anim_player.is_playing():
		fx_anim_player.play("pulse")
	if iron_amount == 0:
		emit_signal("died")
		undock()
		shrink()
	return mined


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
