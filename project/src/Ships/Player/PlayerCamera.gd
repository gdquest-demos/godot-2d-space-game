# The main camera that follows the location of the player. It manages
# zooming out when the map button is pressed, and manages the creation
# of a duplicate itself that will live in the minimap viewport, and will follow
# the original's position in the world using a `RemoteTransform2D`.
extends Camera2D

export var max_zoom := 5.0

var _start_zoom := zoom
var _start_position := Vector2.ZERO

onready var remote_map := $RemoteMap
onready var remote_distort := $RemoteDistort
onready var tween := $Tween


func _ready() -> void:
	Events.connect("map_toggled", self, "_toggle_map")


func setup_camera_map(map: Viewport) -> void:
	var camera_map := self.duplicate()
	map.add_child(camera_map)
	remote_map.remote_path = camera_map.get_path()


func setup_distortion_camera() -> void:
	var distort_camera := self.duplicate()
	ObjectRegistry.register_distortion_effect(distort_camera)
	remote_distort.remote_path = distort_camera.get_path()


func _toggle_map(show: bool, duration: float) -> void:
	if show:
		tween.interpolate_property(
			self, "zoom", zoom, _start_zoom, duration, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN
		)
	else:
		_start_position = position
		tween.interpolate_property(
			self,
			"zoom",
			zoom,
			Vector2(max_zoom, max_zoom),
			duration,
			Tween.TRANS_LINEAR,
			Tween.EASE_OUT_IN
		)
	tween.start()
