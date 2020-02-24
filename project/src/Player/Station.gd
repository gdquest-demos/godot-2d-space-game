extends "res://src/Common/DockingPoint/DockingPoint.gd"

signal upgrade_point_hit

export var upgrade_iron_amount := 99.0

var accumulated_iron := 0.0 setget _set_accumulated_iron


func _ready() -> void:
	Events.connect("upgrade_choice_made", self, "_on_Upgrade_Choice_made")


func _set_accumulated_iron(value: float) -> void:
	accumulated_iron = value
	if accumulated_iron >= upgrade_iron_amount:
		accumulated_iron = 0
		Events.emit_signal("upgrade_point_hit")


func _on_Upgrade_Choice_made(_choice: int) -> void:
	upgrade_iron_amount *= 1.25
