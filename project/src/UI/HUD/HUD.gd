extends Control

onready var shield_bar := $ShieldBar
onready var cargo_gauge := $CargoGauge


func initialize(player: PlayerShip) -> void:
	shield_bar.initialize(player)
	cargo_gauge.initialize(player)
