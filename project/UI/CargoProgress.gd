extends ProgressBar

@export var Ore: PackedScene = preload("res://World/Ores/IronOre.tscn")

@onready var arc_bottom := $ArcBottom
@onready var arc_top := $ArcTop
@onready var fill := $Fill
@onready var tween : Tween
@onready var anim_player := $AnimationPlayer
@onready var audio_unload: AudioStreamPlayer = $AudioUnload

var docked_position := Vector2.ZERO

var _player_is_mining := false


func _ready() -> void:
	Events.connect("docked", Callable(self, "_on_Events_docked"))
	Events.connect("mine_started", Callable(self, "_on_Events_mine_started"))
	Events.connect("mine_finished", Callable(self, "_on_Events_mine_finished"))
	self.connect("value_changed", Callable(self, "_on_value_changed"))
	share(arc_bottom)
	share(arc_top)


func initialize(player: PlayerShip) -> void:
	player.cargo.stats.connect("stat_changed", Callable(self, "_on_Stats_stat_changed"))
	max_value = player.cargo.stats.get_max_cargo()
	value = player.cargo.stats.get_stat("cargo")


func spawn_ore() -> void:
	var ore := Ore.instantiate()
	add_child(ore)
	if _player_is_mining:
		ore.global_position = docked_position
		ore.animate_to(global_position + pivot_offset)
	else:
		ore.global_position = global_position + pivot_offset
		ore.animate_to(docked_position)
		audio_unload.play()


func _on_Events_docked(docking_point: DockingPoint) -> void:
	docked_position = docking_point.get_global_transform_with_canvas().origin


func _on_Events_mine_started(_mining_position: Vector2) -> void:
	_player_is_mining = true


func _on_Events_mine_finished() -> void:
	_player_is_mining = false


func _on_Stats_stat_changed(stat: String, _value_start: float, current_value: float) -> void:
	if not stat == "cargo":
		return
	value = current_value


func _on_value_changed(_value: float) -> void:
	if tween and tween.is_running():
		return
	tween = create_tween()
	tween.tween_property(
		fill,
		"scale",
		Vector2(ratio, ratio),
		0.25
	).from_current().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.play()
	spawn_ore()
