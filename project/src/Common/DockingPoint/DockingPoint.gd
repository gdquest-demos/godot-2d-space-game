extends Node2D


signal emptied


export var map_icon: Texture
export var color := Color.beige
export var docking_distance := 200.0 setget _set_docking_distance
export var debug_draw_docking_radius := true setget _set_debug_draw_docking_radius
export var debug_docking_color_normal := Color(0, 1, 0, 0.05)
export var debug_docking_color_highlight := Color(0, 1, 0, 0.2)

var angle_proportion := 1.0
var player_inside := false
var radius: float
var docking_point_edge: Vector2

onready var docking_shape := $DockingArea/CollisionShape2D
onready var collision_shape := $KinematicBody2D/CollisionShape2D
onready var agent_location := GSTSteeringAgent.new()
onready var remote_rig := $RemoteRig
onready var remote_transform := $RemoteRig/RemoteTransform2D


func _ready() -> void:
	radius = collision_shape.shape.radius
	agent_location.position.x = global_position.x
	agent_location.position.y = global_position.y
	agent_location.orientation = rotation
	agent_location.bounding_radius = radius
	docking_point_edge = Vector2.UP * radius
	
	$DockingArea.connect("body_entered", self, "_on_DockingArea_body_entered")
	$DockingArea.connect("body_exited", self, "_on_DockingArea_body_exited")


func _draw() -> void:
	if debug_draw_docking_radius:
		var color := (
				debug_docking_color_normal if not player_inside else
				debug_docking_color_highlight
		)
		draw_circle(Vector2.ZERO, docking_distance, color)


func set_docking_remote(node: Node2D, docker_distance: float) -> void:
	remote_rig.rotation = GSTUtils.vector3_to_angle(
			GSTUtils.to_vector3(node.global_position - global_position)
	)
	remote_transform.position = docking_point_edge + Vector2.UP*docker_distance
	remote_transform.remote_path = node.get_path()


func undock() -> void:
	remote_transform.remote_path = ""


func register_on_map(map: Viewport) -> void:
	var id: int = map.register_map_object($MapTransform, map_icon)
	connect("emptied", map, "remove_map_object", [id])


func _set_debug_draw_docking_radius(value: bool) -> void:
	debug_draw_docking_radius = value
	update()


func _set_docking_distance(value: float) -> void:
	docking_distance = value
	if not is_inside_tree():
		yield(self, "ready")
	
	docking_shape.shape.radius = value
	update()


func _on_DockingArea_body_entered(body: Node) -> void:
	player_inside = true
	body.can_dock = true
	body.dockable = self
	update()


func _on_DockingArea_body_exited(body: Node) -> void:
	player_inside = false
	body.can_dock = false
	update()
