# Animated shield bar for the Player's ship.
extends TextureProgressBar

@export var gradient: Gradient
@export var stats: Resource = preload("res://ships/player/player_stats.tres") as StatsShip
@export var danger_threshold := 0.3

@onready var tween : Tween
@onready var anim_player := $AnimationPlayer


func initialize(player: PlayerShip) -> void:
	player.stats.stat_changed.connect(_on_Stats_stat_changed)
	max_value = player.stats.get_max_health()
	value = player.stats.get("health")
	tint_progress = gradient.sample(value / max_value)


func _on_Stats_stat_changed(stat: String, value_start: float, current_value: float) -> void:
	if not stat == "health":
		return
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.step_finished.connect(_on_Tween_step_finished)
	tween.tween_property(
		self, "value", current_value, 0.25
	).from(value_start).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.play()
	anim_player.play("damage")


func _on_Tween_step_finished(_idx: int) -> void:
	var shield_ratio := value / max_value
	var gradient_color := gradient.sample(shield_ratio)
	tint_progress = gradient_color

	if shield_ratio <= danger_threshold:
		var anim: Animation = anim_player.get_animation("danger")
		var final_tint := gradient_color + Color(1.0, 1.0, 1.0, 0.0)
		anim.track_set_key_value(0, 0, gradient_color)
		anim.track_set_key_value(0, 1, final_tint)
		anim_player.play("danger")
