extends ProgressBar

export var stats: Resource = preload("res://src/Ships/Player/cargo_stats.tres") as Stats

onready var arc_bot := $ArcBot
onready var arc_top := $ArcTop
onready var fill := $Fill
onready var tween := $Tween
onready var anim_player := $AnimationPlayer

func _ready() -> void:
	share(arc_bot)
	share(arc_top)
	initialize()


func initialize() -> void:
	stats.connect("stat_changed", self, "_on_Stats_stat_changed")
	max_value = stats.get("_max_cargo")
	value = stats.get("cargo")


func _on_Stats_stat_changed(stat: String, value_start: float, current_value: float) -> void:
	if not stat == "cargo":
		return
	value = current_value


func _on_value_changed(value: float) -> void:
	if tween.is_active():
		return
	tween.interpolate_property(fill, "rect_scale", fill.rect_scale,
			Vector2(ratio, ratio), 0.25, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
