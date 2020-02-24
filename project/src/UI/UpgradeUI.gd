extends MarginContainer

onready var health_up_button := $HBoxContainer/HealthUpgrade
onready var speed_up_button := $HBoxContainer/SpeedUpgrade
onready var cargo_up_button := $HBoxContainer/CargoUpgrade
onready var mine_up_button := $HBoxContainer/MineSpeedUpgrade
onready var weapon_up_button := $HBoxContainer/WeaponUpgrade


func _ready() -> void:
		health_up_button.connect("button_down", self, "_on_Health_button_down")
		speed_up_button.connect("button_down", self, "_on_Speed_button_down")
		cargo_up_button.connect("button_down", self, "_on_Cargo_button_down")
		mine_up_button.connect("button_down", self, "_on_Mine_button_down")
		weapon_up_button.connect("button_down", self, "_on_Weapon_button_down")


func _on_Health_button_down() -> void:
	Events.emit_signal("upgrade_choice_made", Events.UpgradeChoices.HEALTH)


func _on_Speed_button_down() -> void:
	Events.emit_signal("upgrade_choice_made", Events.UpgradeChoices.SPEED)


func _on_Cargo_button_down() -> void:
	Events.emit_signal("upgrade_choice_made", Events.UpgradeChoices.CARGO)


func _on_Mine_button_down() -> void:
	Events.emit_signal("upgrade_choice_made", Events.UpgradeChoices.MINING)


func _on_Weapon_button_down() -> void:
	Events.emit_signal("upgrade_choice_made", Events.UpgradeChoices.WEAPON)
