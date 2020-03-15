# Animated shield bar for the Player's ship.
extends TextureProgress

export var gradient: Gradient
export var stats: Resource = preload("res://src/Ships/Player/player_stats.tres") as StatsShip
export var danger_threshold := 0.3

onready var tween := $Tween
onready var anim_player := $AnimationPlayer


func _ready() -> void:
	tween.connect("tween_step", self, "_on_Tween_tween_step")


func initialize(player: PlayerShip) -> void:
	player.stats.connect("stat_changed", self, "_on_Stats_stat_changed")
	max_value = player.stats.get_max_health()
	value = player.stats.get("health")
	tint_progress = gradient.interpolate(value / max_value)


func _on_Stats_stat_changed(stat: String, value_start: float, current_value: float) -> void:
	if not stat == "health":
		return
	if tween.is_active():
		tween.stop_all()
	tween.interpolate_property(
		self, "value", value_start, current_value, 0.25, Tween.TRANS_ELASTIC, Tween.EASE_OUT
	)
	tween.start()
	anim_player.play("damage")


func _on_Tween_tween_step(_object: Object, _key: NodePath, _elapsed: float, _tween_value: Object) -> void:
	var shield_ratio := value / max_value
	var gradient_color := gradient.interpolate(shield_ratio)
	tint_progress = gradient_color

	if shield_ratio <= danger_threshold:
		var anim: Animation = anim_player.get_animation("danger")
		var final_tint := gradient_color + Color(1.0, 1.0, 1.0, 0.0)
		anim.track_set_key_value(0, 0, gradient_color)
		anim.track_set_key_value(0, 1, final_tint)
		anim_player.play("danger")
