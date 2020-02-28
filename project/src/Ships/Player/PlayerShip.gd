# Main class to represent the player's physics body. Controls the player's
# current health and how to operate when an upgrade choice has been made.
extends KinematicBody2D

signal died

export var max_health := 100
export (int, LAYERS_2D_PHYSICS) var projectile_mask := 0
export var PopEffect: PackedScene
# Represents the ship on the minimap. Use a MapIcon resource.
export var map_icon: Resource

var dockables := []
var _health := max_health

onready var shape := $CollisionShape
onready var agent: GSAISteeringAgent = $StateMachine/Move.agent
onready var camera_transform := $CameraTransform
onready var timer := $MapTimer
onready var cargo := $Cargo
onready var cargo_bar := $BarRig/PlayerUI/Cargo
onready var health_bar := $BarRig/PlayerUI/Health
onready var move_state := $StateMachine/Move
onready var gun := $Gun


func _ready() -> void:
	Events.connect("damaged", self, "_on_damaged")
	Events.connect("upgrade_choice_made", self, "_on_Upgrade_Choice_made")

	health_bar.max_value = max_health
	health_bar.value = _health

	gun.projectile_mask = projectile_mask


func _toggle_map(map_up: bool, tween_time: float) -> void:
	if not map_up:
		timer.start(tween_time)
		yield(timer, "timeout")
	camera_transform.update_position = not map_up


func die() -> void:
	var effect := PopEffect.instance()
	effect.global_position = global_position
	ObjectRegistry.register_effect(effect)

	emit_signal("died")
	Events.emit_signal("player_died")

	queue_free()


func register_on_map(map: Viewport) -> void:
	var id: int = map.register_map_object($MapTransform, map_icon)
	connect("died", map, "remove_map_object", [self, id])


func grab_camera(camera: Camera2D) -> void:
	camera_transform.remote_path = camera.get_path()


func _on_damaged(target: Node, amount: int, _origin: Node) -> void:
	if not target == self:
		return

	_health -= amount
	health_bar.value = _health
	if _health <= 0:
		die()


func _on_Upgrade_Choice_made(choice: int) -> void:
	match choice:
		Events.UpgradeChoices.HEALTH:
			max_health += 15
			_health = max_health
			health_bar.max_value = max_health
			health_bar.value = _health
		Events.UpgradeChoices.SPEED:
			move_state.linear_speed_max += 75
			agent.linear_speed_max += 75
		Events.UpgradeChoices.CARGO:
			cargo.max_cargo += 50
			cargo_bar.max_value += 50
		Events.UpgradeChoices.MINING:
			cargo.mining_rate += 10
			cargo.unload_rate = max(cargo.unload_rate + 5, cargo.mining_rate)
		Events.UpgradeChoices.WEAPON:
			gun.damage_bonus += 2
			gun.cooldown.wait_time *= 0.9
