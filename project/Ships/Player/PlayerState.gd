# Boilerplate for player-specific states
# Gives autocompletion for the player
class_name PlayerState
extends State

var ship: PlayerShip


func _ready() -> void:
	yield(owner, "ready")
	ship = owner
