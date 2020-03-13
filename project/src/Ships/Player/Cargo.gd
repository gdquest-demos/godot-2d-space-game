# Worker node on the player ship that manages and maintains cargo and mining
# from mineables.
class_name Cargo
extends Node

enum States { IDLE, MINING, UNLOADING }

export var stats: Resource = preload("res://src/Ships/Player/cargo_stats.tres") as StatsCargo

var state: int = States.IDLE
var is_mining := false
var is_exporting := false
var dockable_weakref: WeakRef


func _ready() -> void:
	stats.initialize()
	Events.connect("docked", self, "_on_Player_docked")
	Events.connect("undocked", self, "_on_Player_undocked")
	yield(owner, "ready")


func _physics_process(delta: float) -> void:
	match state:
		States.MINING:
			if stats.cargo == stats.get_max_cargo():
				state = States.IDLE

			var _asteroid: Asteroid = dockable_weakref.get_ref()
			if not _asteroid:
				state = States.IDLE
				Events.emit_signal("force_undock")
			else:
				var mined: float = _asteroid.mine_amount(
					min(stats.get_max_cargo(), stats.get_mining_rate() * delta)
				)
				if mined == 0:
					Events.emit_signal("force_undock")
					state = States.IDLE
				else:
					stats.cargo += mined
		States.UNLOADING:
			if stats.cargo == 0:
				state = States.IDLE

			var _station: Station = dockable_weakref.get_ref()
			if not _station:
				state = States.IDLE
				Events.emit_signal("force_undock")
			else:
				var export_amount := min(stats.get_unload_rate() * delta, stats.cargo)
				stats.cargo -= export_amount
				_station.accumulated_iron += export_amount
		States.IDLE:
			Events.emit_signal("mine_finished")


func _on_Player_docked(dockable: Node) -> void:
	dockable_weakref = weakref(dockable)
	if dockable is Station:
		state = States.UNLOADING
	elif dockable is Asteroid:
		state = States.MINING
		var asteroid_position: Vector2 = dockable.get_global_transform_with_canvas().origin
		Events.emit_signal("mine_started", asteroid_position)


func _on_Player_undocked() -> void:
	state = States.IDLE
