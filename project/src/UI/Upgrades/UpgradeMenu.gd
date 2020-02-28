# Connects the press of the various upgrade buttons to emitting a signal that
# indicates an upgrade - the player reacts by improving what was selected,
# and pirates spawn.
extends Control
# TODO: in the future, build the menu from available upgrades and related data?

onready var health_button := $HBoxContainer/HealthUpgrade
onready var speed_button := $HBoxContainer/SpeedUpgrade
onready var cargo_button := $HBoxContainer/CargoUpgrade
onready var mine_button := $HBoxContainer/MiningUpgrade
onready var weapon_button := $HBoxContainer/WeaponUpgrade


func _ready() -> void:
	health_button.connect("button_down", self, "select_upgrade", [Events.UpgradeChoices.HEALTH])
	speed_button.connect("button_down", self, "select_upgrade", [Events.UpgradeChoices.SPEED])
	cargo_button.connect("button_down", self, "select_upgrade", [Events.UpgradeChoices.CARGO])
	mine_button.connect("button_down", self, "select_upgrade", [Events.UpgradeChoices.MINING])
	weapon_button.connect("button_down", self, "select_upgrade", [Events.UpgradeChoices.WEAPON])


func open() -> void:
	get_tree().paused = true
	show()
	health_button.grab_focus()


# Emit a signal through the Events signal bus to transfer the upgrade selected by the player.
func select_upgrade(type: int) -> void:
	get_tree().paused = false
	hide()
	Events.emit_signal("upgrade_choice_made", type)
