# Animated bar that reacts to changes in properties from a Stats resource.
# Pass the stats instance to the `initialize` method to make the bar work.
class_name AnimatedBar
extends Range

@onready var tween: Tween

var stat_value := ""
var stat_max := ""


func initialize(stats: Stats, _stat_value: String, _stat_max: String) -> void:
	stat_value = _stat_value
	stat_max = _stat_max
	stats.stat_changed.connect(_on_Stats_stat_changed)
	max_value = stats.get_stat(stat_max)
	animate(stats.get_stat(stat_value))


func animate(target_value: float) -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(
		self, "value", target_value, 0.5
	).from(value).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.play()


func _on_Stats_stat_changed(stat_name: String, _old_value: float, new_value: float) -> void:
	if not stat_name in [stat_value, stat_name]:
		return
	match stat_name:
		stat_max:
			max_value = new_value
		stat_value:
			animate(new_value)
