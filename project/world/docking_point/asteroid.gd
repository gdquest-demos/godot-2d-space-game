# Represents an extended dockable that holds a random amount of mineable
# resources.
class_name Asteroid
extends DockingPoint

signal mined(amount)
signal depleted

@export var min_iron_amount := 5.0
@export var max_iron_amount := 100.0
@export var min_scale := 0.2

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var fx_anim_player: AnimationPlayer = $FXAnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var iron_amount := 0.0


func _ready() -> void:
	super()
	anim_player.speed_scale = randf_range(0.5, 2.0)


func setup(rng: RandomNumberGenerator) -> void:
	iron_amount = rng.randf_range(min_iron_amount, max_iron_amount)
	scale *= max(iron_amount / max_iron_amount, min_scale)


func mine_amount(value: float) -> float:
	var mined_amount: float = min(iron_amount, value)
	iron_amount -= mined_amount
	mined.emit(mined_amount)

	if is_equal_approx(iron_amount, 0.0):
		undock()
		shrink()
	elif not anim_player.is_playing():
		fx_anim_player.play("pulse")

	return mined_amount


# Animates the asteroid shrinking down and frees it.
func shrink() -> void:
	var fx_tween = create_tween()
	if fx_anim_player.is_playing():
		fx_anim_player.stop(false)
	fx_tween.tween_property(
		sprite, "scale", Vector2.ZERO, 0.25
	).from_current().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	fx_tween.tween_property(
		dock_aura, "scale", Vector2.ZERO, 0.5
	).from_current().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	fx_tween.play()
	await fx_tween.finished
	queue_free()


func _on_DockingArea_body_entered(body: Node) -> void:
	super._on_DockingArea_body_entered(body)
	anim_player.stop(false)


func _on_DockingArea_body_exited(body: Node) -> void:
	super._on_DockingArea_body_exited(body)
	anim_player.play()
