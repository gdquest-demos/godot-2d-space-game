extends Node

export var cargo_size := 100.0
export var mining_strength := 10.0
export var export_strength := 35.0

var current_cargo := 0.0 setget _set_current_cargo
var is_mining := false
var is_exporting := false
var dockee: WeakRef
var cargo_bar: ProgressBar


func _ready() -> void:
	yield(owner, "ready")
	cargo_bar = owner.cargo_bar


func _physics_process(delta: float) -> void:
	if is_mining:
		if current_cargo >= cargo_size:
			is_mining = false

		if is_mining:
			var _dockee: Node2D = dockee.get_ref()
			if not _dockee:
				is_mining = false
				Events.emit_signal("force_undock")
			else:
				var mined: float = _dockee.mine_amount(min(cargo_size, mining_strength * delta))
				if mined == 0:
					is_mining = false
				else:
					_set_current_cargo(current_cargo + mined)
	elif is_exporting:
		if current_cargo == 0:
			is_exporting = false

		if is_exporting:
			var _dockee: Node2D = dockee.get_ref()
			if not _dockee:
				is_exporting = false
				Events.emit_signal("force_undock")
			else:
				var export_amount := min(export_strength * delta, current_cargo)
				_set_current_cargo(max(0, current_cargo - export_amount))
				_dockee.accumulated_iron += export_amount


func _on_Player_docked(_dockee: Node) -> void:
	dockee = weakref(_dockee)
	if _dockee.is_in_group("Depositables"):
		is_exporting = true
	elif _dockee.is_in_group("Mineables"):
		is_mining = true


func _on_Player_undocked() -> void:
	is_mining = false
	is_exporting = false


func _set_current_cargo(value: float) -> void:
	current_cargo = value
	var percentage := current_cargo / cargo_size
	cargo_bar.value = percentage * cargo_bar.max_value
