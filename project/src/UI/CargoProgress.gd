extends ProgressBar

export var stats: Resource = preload("res://src/Ships/Player/cargo_stats.tres") as Stats
export var ore_scene: PackedScene = preload("res://src/World/Ores/IronOre.tscn")

onready var arc_bot := $ArcBot
onready var arc_top := $ArcTop
onready var fill := $Fill
onready var tween := $Tween
onready var anim_player := $AnimationPlayer

var asteroid_position := Vector2.ZERO

var _mining: = false

func _ready() -> void:
	Events.connect("mine_started", self, "_on_Events_mine_started")
	Events.connect("mine_finished", self, "_on_Events_mine_finished")
	share(arc_bot)
	share(arc_top)
	initialize()


func initialize() -> void:
	stats.connect("stat_changed", self, "_on_Stats_stat_changed")
	max_value = stats.get("_max_cargo")
	value = stats.get("cargo")


func spawn_ore() -> void:
	if not _mining:
		return
	var instance := ore_scene.instance()
	add_child(instance)
	instance.global_position = asteroid_position
	instance.target_position = rect_global_position + rect_pivot_offset
	instance.tween()


func _on_Events_mine_started(mining_position: Vector2) -> void:
	asteroid_position = mining_position
	_mining = true


func _on_Events_mine_finished() -> void:
	_mining = false


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
	spawn_ore()
