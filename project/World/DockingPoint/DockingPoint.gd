# A class that represents a dockable object in space that the player can attach
# to. Synchronizes with the docking ship, taking control of it with a remote
# transform, as well as indicating docking range being achieved or lost by
# animating a docking range circle.
class_name DockingPoint
extends Node2D

signal died

export (Resource) var map_icon = MapIcon.new()
export var docking_distance := 200.0 setget _set_docking_distance

var angle_proportion := 1.0
var is_player_inside := false
var radius := 0.0
var docking_point_edge := Vector2.ZERO

onready var docking_shape: CollisionShape2D = $DockingArea/CollisionShape2D
onready var docking_area: Area2D = $DockingArea
onready var collision_shape: CollisionShape2D = $KinematicBody2D/CollisionShape2D
onready var agent_location := GSAISteeringAgent.new()
onready var ref_to := weakref(self)
onready var tween := $TweenAura
onready var dock_aura := $DockingAura
onready var player_rotation_transform = $Sprite/PlayerRotationRig/PlayerRotationRemoteTransform
onready var player_rotation_transform_rig = $Sprite/PlayerRotationRig


func _ready() -> void:
	player_rotation_transform_rig.scale = Vector2.ONE / $Sprite.scale
	radius = collision_shape.shape.radius
	agent_location.position.x = global_position.x
	agent_location.position.y = global_position.y
	agent_location.orientation = rotation
	agent_location.bounding_radius = radius
	docking_point_edge = Vector2.UP * radius

	docking_area.connect("body_entered", self, "_on_DockingArea_body_entered")
	docking_area.connect("body_exited", self, "_on_DockingArea_body_exited")

	var docking_diameter := docking_distance * 2
	tween.scale_final = Vector2.ONE * (docking_diameter / dock_aura.texture.get_width())


func set_docking_remote(node: Node2D, docker_distance: float) -> void:
	player_rotation_transform_rig.global_rotation = GSAIUtils.vector2_to_angle(node.global_position - global_position)
	player_rotation_transform.position = docking_point_edge + Vector2.UP * (docker_distance / scale.x)
	player_rotation_transform.remote_path = node.get_path()

func undock() -> void:
	player_rotation_transform.remote_path = ""


func _set_docking_distance(value: float) -> void:
	docking_distance = value
	if not is_inside_tree():
		yield(self, "ready")

	docking_shape.shape.radius = value


func _on_DockingArea_body_entered(body: Node) -> void:
	is_player_inside = true
	body.dockables.append(ref_to)
	if tween.is_active():
		tween.stop_all()
	tween.make_appear(dock_aura)


func _on_DockingArea_body_exited(body: Node) -> void:
	is_player_inside = false
	var index: int = body.dockables.find(ref_to)
	if index > -1:
		body.dockables.remove(index)
	if tween.is_active():
		tween.stop_all()
	tween.make_disappear(dock_aura)
