extends Node

enum States { IDLE, MINING, UNLOADING }

export var max_cargo := 100.0
export var mining_rate := 10.0
export var unload_rate := 35.0

var state: int = States.IDLE
var cargo := 0.0 setget set_cargo
var is_mining := false
var is_exporting := false
var dockable_weakref: WeakRef
var cargo_bar: ProgressBar


func _ready() -> void:
	Events.connect("docked", self, "_on_Player_docked")
	Events.connect("undocked", self, "_on_Player_undocked")
	yield(owner, "ready")
	cargo_bar = owner.cargo_bar


func _physics_process(delta: float) -> void:
	match state:
		States.MINING:
			if cargo == max_cargo:
				state = States.IDLE

			var _asteroid: Asteroid = dockable_weakref.get_ref()
			if not _asteroid:
				state = States.IDLE
				Events.emit_signal("force_undock")
			else:
				var mined: float = _asteroid.mine_amount(min(max_cargo, mining_rate * delta))
				if mined == 0:
					state = States.IDLE
				else:
					self.cargo += mined
		States.UNLOADING:
			if cargo == 0:
				state = States.IDLE

			var _station: Station = dockable_weakref.get_ref()
			if not _station:
				state = States.IDLE
				Events.emit_signal("force_undock")
			else:
				var export_amount := min(unload_rate * delta, cargo)
				set_cargo(max(0, cargo - export_amount))
				_station.accumulated_iron += export_amount


func _on_Player_docked(dockable: Node) -> void:
	dockable_weakref = weakref(dockable)
	if dockable is Station:
		state = States.UNLOADING
	elif dockable is Asteroid:
		state = States.MINING


func _on_Player_undocked() -> void:
	state = States.IDLE


func set_cargo(value: float) -> void:
	cargo = min(value, max_cargo)
	var percentage := cargo / max_cargo
	cargo_bar.value = percentage * cargo_bar.max_value
