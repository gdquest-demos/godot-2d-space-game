extends KinematicBody2D

signal died

export var map_icon: Texture
export var color_map_icon := Color.white
export var scale_map_icon := 0.5
export var health_max := 100
export (int, LAYERS_2D_PHYSICS) var projectile_mask := 0
export var PopEffect: PackedScene

var can_dock := 0
var dockables := []
var _health := health_max

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
	Events.connect("damaged", self, "_on_self_damaged")
	$Gun.projectile_mask = projectile_mask
	Events.connect("docked", cargo, "_on_Player_docked")
	Events.connect("undocked", cargo, "_on_Player_undocked")
	health_bar.max_value = health_max
	health_bar.value = _health
	Events.connect("upgrade_choice_made", self, "_on_Upgrade_Choice_made")


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

	queue_free()


func register_on_map(map: Viewport) -> void:
	var id: int = map.register_map_object($MapTransform, map_icon, color_map_icon, scale_map_icon)
	connect("died", map, "remove_map_object", [self, id])


func grab_camera(camera: Camera2D) -> void:
	camera_transform.remote_path = camera.get_path()


func _on_self_damaged(target: Node, amount: int, _origin: Node) -> void:
	if not target == self:
		return
	
	_health -= amount
	health_bar.value = _health
	if _health <= 0:
		die()


func _on_Upgrade_Choice_made(choice: int) -> void:
	match choice:
		Events.UpgradeChoices.HEALTH:
			health_max += 15
			_health = health_max
			health_bar.max_value = health_max
			health_bar.value = _health
		Events.UpgradeChoices.SPEED:
			move_state.linear_speed_max += 75
			agent.linear_speed_max += 75
		Events.UpgradeChoices.CARGO:
			cargo.cargo_size += 50
			cargo_bar.max_value += 50
		Events.UpgradeChoices.MINING:
			cargo.mining_strength += 10
			cargo.export_strength = max(cargo.export_strength+5, cargo.mining_strength)
		Events.UpgradeChoices.WEAPON:
			gun.damage_bonus += 2
			gun.cooldown.wait_time *= 0.9
