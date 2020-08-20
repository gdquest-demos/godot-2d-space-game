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
onready var hbox_container := $HBoxContainer
onready var button_count := $HBoxContainer.get_child_count();


func _ready() -> void:
	health_button.connect("button_down", self, "select_upgrade", [Events.UpgradeChoices.HEALTH])
	speed_button.connect("button_down", self, "select_upgrade", [Events.UpgradeChoices.SPEED])
	cargo_button.connect("button_down", self, "select_upgrade", [Events.UpgradeChoices.CARGO])
	mine_button.connect("button_down", self, "select_upgrade", [Events.UpgradeChoices.MINING])
	weapon_button.connect("button_down", self, "select_upgrade", [Events.UpgradeChoices.WEAPON])


func open() -> void:
	get_tree().paused = true
	health_button.grab_focus()
	for i in range(button_count):
		var button = hbox_container.get_child(i)
		button.show_delayed(i * 0.1)
	show()

# Emit a signal through the Events signal bus to transfer the upgrade selected by the player.
func select_upgrade(type: int) -> void:
	get_tree().paused = false
	Events.emit_signal("upgrade_chosen", type)
	for i in range(button_count):
		var button = hbox_container.get_child(i)
		button.hide_delayed(i * 0.1)
	yield(hbox_container.get_child(button_count - 1), "on_hide_complete")
	hide()
