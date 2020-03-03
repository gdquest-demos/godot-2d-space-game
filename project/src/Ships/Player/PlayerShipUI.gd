extends Control

onready var health_bar: AnimatedBar = $HealthBar
onready var cargo_bar: AnimatedBar = $CargoBar


func initialize(player_ship, cargo) -> void:
	health_bar.initialize(player_ship.stats, "health", "max_health")
	cargo_bar.initialize(cargo.stats, "cargo", "max_cargo")
