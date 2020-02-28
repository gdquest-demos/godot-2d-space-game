class_name DockingPoint
extends Node2D

signal died

export(Resource) var map_icon = MapIcon.new()
export var docking_distance := 200.0 setget _set_docking_distance
export var docking_color_highlight := Color(0, 1, 0, 0.2)

var angle_proportion := 1.0
var is_player_inside := false
var radius := 0.0
var docking_point_edge := Vector2.ZERO

onready var docking_color_normal := Color(
	docking_color_highlight.r, docking_color_highlight.g, docking_color_highlight.b, 0
)
onready var current_color := docking_color_normal
onready var docking_shape: CollisionShape2D = $DockingArea/CollisionShape2D
onready var docking_area: Area2D = $DockingArea
onready var collision_shape: CollisionShape2D = $KinematicBody2D/CollisionShape2D
onready var agent_location := GSAISteeringAgent.new()
onready var remote_rig: Node2D = $RemoteRig
onready var remote_transform: RemoteTransform2D = $RemoteRig/RemoteTransform2D
onready var ref_to := weakref(self)
onready var tween := $Tween


func _ready() -> void:
	radius = collision_shape.shape.radius
	agent_location.position.x = global_position.x
	agent_location.position.y = global_position.y
	agent_location.orientation = rotation
	agent_location.bounding_radius = radius
	docking_point_edge = Vector2.UP * radius

	# warning-ignore:return_value_discarded
	docking_area.connect("body_entered", self, "_on_DockingArea_body_entered")
	# warning-ignore:return_value_discarded
	docking_area.connect("body_exited", self, "_on_DockingArea_body_exited")


func _draw() -> void:
	draw_circle(Vector2.ZERO, docking_distance, current_color)


func set_docking_remote(node: Node2D, docker_distance: float) -> void:
	remote_rig.global_rotation = GSAIUtils.vector2_to_angle(node.global_position - global_position)
	remote_transform.position = docking_point_edge + Vector2.UP * (docker_distance / scale.x)
	remote_transform.remote_path = node.get_path()


func undock() -> void:
	remote_transform.remote_path = ""


func register_on_map(map: Viewport) -> void:
	var id: int = map.register_map_object($MapTransform, map_icon)
	# warning-ignore:return_value_discarded
	connect("died", map, "remove_map_object", [id])


func _set_docking_distance(value: float) -> void:
	docking_distance = value
	if not is_inside_tree():
		yield(self, "ready")

	docking_shape.shape.radius = value
	update()


func _on_DockingArea_body_entered(body: Node) -> void:
	is_player_inside = true
	body.dockables.append(ref_to)
	tween.interpolate_method(
		self,
		"_on_Tween_color_callback",
		current_color,
		docking_color_highlight,
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	tween.start()


func _on_DockingArea_body_exited(body: Node) -> void:
	is_player_inside = false
	var index: int = body.dockables.find(ref_to)
	if index > -1:
		body.dockables.remove(index)
	tween.interpolate_method(
		self,
		"_on_Tween_color_callback",
		current_color,
		docking_color_normal,
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT_IN
	)
	tween.start()


func _on_Tween_color_callback(current: Color) -> void:
	current_color = current
	update()
