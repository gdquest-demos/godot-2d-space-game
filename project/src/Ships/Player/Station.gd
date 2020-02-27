extends DockingPoint

export var upgrade_iron_amount := 99.0

var accumulated_iron := 0.0 setget _set_accumulated_iron


func _set_accumulated_iron(value: float) -> void:
	accumulated_iron = value
	if accumulated_iron >= upgrade_iron_amount:
		accumulated_iron = 0
		Events.emit_signal("upgrade_unlocked", Events.UITypes.UPGRADE)
		upgrade_iron_amount *= 1.25
