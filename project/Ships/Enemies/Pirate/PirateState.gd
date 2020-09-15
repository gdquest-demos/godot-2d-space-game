# Boilerplate for Pirate-specific states
# Gives autocompletion for the Pirate
class_name PirateState
extends State

var ship: PirateShip


func _ready() -> void:
	yield(owner, "ready")
	ship = owner
