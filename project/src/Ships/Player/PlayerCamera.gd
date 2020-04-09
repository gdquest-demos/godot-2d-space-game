# The main camera that follows the location of the player. It manages
# zooming out when the map button is pressed, and manages the creation
# of a duplicate itself that will live in the minimap viewport, and will follow
# the original's position in the world using a `RemoteTransform2D`.
extends Camera2D

export var max_zoom := 5.0
export var shake_strength := 20

var _start_zoom := zoom
var _start_position := Vector2.ZERO
var _is_shaking := false

onready var remote_map := $RemoteMap
onready var remote_distort := $RemoteDistort
onready var tween := $Tween
onready var timer := $ShakeDuration



func _ready() -> void:
	Events.connect("map_toggled", self, "_toggle_map")
	Events.connect("shake", self, "shake")
	set_process(false)


func _process(delta: float) -> void:
	offset = Vector2(
		rand_range(-shake_strength, shake_strength),
		rand_range(-shake_strength, shake_strength)
		)


func setup_camera_map(map: MapView) -> void:
	var camera_map := self.duplicate()
	map.register_camera(camera_map)
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


func shake(duration := -1) -> void:
	if _is_shaking:
		return
	timer.start(duration)
	_is_shaking = true
	set_process(_is_shaking)


func _on_ShakeDuration_timeout() -> void:
	offset = Vector2.ZERO
	rotation_degrees = 0
	_is_shaking = false
	set_process(_is_shaking)
