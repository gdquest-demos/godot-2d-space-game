# Connects the press of the various upgrade buttons to emitting a signal that
# indicates an upgrade - the player reacts by improving what was selected,
# and pirates spawn.
extends Control

@onready var health_button := $HBoxContainer/HealthUpgrade
@onready var speed_button := $HBoxContainer/SpeedUpgrade
@onready var cargo_button := $HBoxContainer/CargoUpgrade
@onready var mine_button := $HBoxContainer/MiningUpgrade
@onready var weapon_button := $HBoxContainer/WeaponUpgrade
@onready var menu_sounds: MenuSoundPlayer = $MenuSoundPlayer

@onready var buttons := $HBoxContainer.get_children()


func _ready() -> void:
	health_button.button_down.connect(select_upgrade.bind(Events.UpgradeChoices.HEALTH))
	speed_button.button_down.connect(select_upgrade.bind(Events.UpgradeChoices.SPEED))
	cargo_button.button_down.connect(select_upgrade.bind(Events.UpgradeChoices.CARGO))
	mine_button.button_down.connect(select_upgrade.bind(Events.UpgradeChoices.MINING))
	weapon_button.button_down.connect(select_upgrade.bind(Events.UpgradeChoices.WEAPON))

	for button in buttons:
		button.focus_entered.connect(_on_Button_focus_entered)


func open() -> void:
	get_tree().paused = true
	health_button.grab_focus()
	for button in buttons:
		var delay: float = button.get_index() * 0.1
		menu_sounds.play_open(delay)
		button.appear(delay)
	show()


# Emit a signal through the Events signal bus to unlock the upgrade selected by the player.
func select_upgrade(type: int) -> void:
	get_tree().paused = false
	Events.upgrade_chosen.emit(type)
	menu_sounds.play_confirm()
	for button in buttons:
		var delay: float = button.get_index() * 0.1
		button.disappear(delay)
	await buttons[-1].disappeared
	hide()


func _on_Button_focus_entered() -> void:
	menu_sounds.play_hide()
