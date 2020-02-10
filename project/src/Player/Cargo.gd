extends Node


export var cargo_size := 100.0
export var mining_strength := 10.0
export var export_strength := 35.0

var current_cargo := 0.0 setget _set_current_cargo
var is_mining := false
var is_exporting := false

onready var bar = $BarRig/ProgressBar


func _ready() -> void:
	$BarRig.set_as_toplevel(true)


func _physics_process(delta: float) -> void:
	if is_mining:
		if current_cargo >= cargo_size:
			is_mining = false
			
		if is_mining:
			_set_current_cargo(min(
					cargo_size,
					current_cargo + mining_strength * delta
			))
	elif is_exporting:
		if current_cargo == 0:
			is_exporting = false
			
		if is_exporting:
			_set_current_cargo(max(0, current_cargo - export_strength * delta))


func _on_Player_docked(dockee: Node) -> void:
	if dockee.is_in_group("Depositables"):
		is_exporting = true
	elif dockee.is_in_group("Mineables"):
		is_mining = true


func _on_Player_undocked() -> void:
	is_mining = false
	is_exporting = false


func _set_current_cargo(value: float) -> void:
	current_cargo = value
	var percentage := current_cargo / cargo_size
	bar.value = percentage * bar.max_value
