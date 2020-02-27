extends Camera2D

export var do_position_when_map_up := true
export var do_position_when_map_down := true
export var max_zoom := 5.0

var _start_zoom := zoom
var _start_position := Vector2.ZERO

onready var remote_transform := $RemoteTransform2D
onready var tween := $Tween


func _ready() -> void:
	Events.connect("map_toggled", self, "_toggle_map")


func setup_camera_map(map: Viewport) -> void:
	var camera_map = self.duplicate()
	camera_map.do_position_when_map_down = false
	camera_map.do_position_when_map_up = false
	map.add_child(camera_map)
	remote_transform.remote_path = camera_map.get_path()


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
