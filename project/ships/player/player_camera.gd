# The main camera that follows the location of the player. It manages
# zooming out when the map button is pressed, and manages the creation
# of a duplicate itself that will live in the minimap viewport, and will follow
# the original's position in the world using a `RemoteTransform2D`.
#
# The camera supports zooming and camera shake.
extends Camera2D

const SHAKE_EXPONENT := 1.8

@export var max_zoom := 5.0
@export var decay_rate := 1.0
@export var shake_offset_multiplier := Vector2(100.0, 100.0)

var shake_amount := 0.0: set = set_shake_amount
var noise_y : float = 0.0

var _start_zoom := zoom
var _start_position := Vector2.ZERO

@onready var remote_map := $RemoteMap
@onready var remote_distort := $RemoteDistort
@onready var tween: Tween
@onready var noise := FastNoiseLite.new()


func _ready() -> void:
	set_physics_process(false)

	Events.map_toggled.connect(_toggle_map)
	Events.explosion_occurred.connect(_on_Events_explosion_occurred)

	randomize()
	noise.seed = randi()
	noise.frequency = 4
	noise.fractal_octaves = 2
	noise.noise_type = FastNoiseLite.TYPE_PERLIN


func _physics_process(delta):
	self.shake_amount -= decay_rate * delta
	noise_y += delta
	shake()


func shake():
	var amount : float = pow(shake_amount, SHAKE_EXPONENT)
	
	if amount == 0:
		return
		
	offset = Vector2(
		shake_offset_multiplier.x * amount * noise.get_noise_2d(noise_y, noise_y / amount),
		shake_offset_multiplier.y * amount * noise.get_noise_2d(noise_y / amount, noise_y)
	)


func set_shake_amount(value):
	shake_amount = clampf(value, 0.0, 1.0)
	set_physics_process(shake_amount != 0.0)


func setup_camera_map(map: MapView) -> void:
	var camera_map := self.duplicate()
	map.register_camera(camera_map)
	remote_map.remote_path = camera_map.get_path()


func setup_distortion_camera() -> void:
	var distort_camera := self.duplicate()
	ObjectRegistry.register_distortion_effect(distort_camera)
	remote_distort.remote_path = distort_camera.get_path()


func _toggle_map(display: bool, duration: float) -> void:
	if tween and tween.is_running:
		tween.kill()
	tween = create_tween()
	if display:
		tween.tween_property(
			self,
			"zoom",
			_start_zoom,
			duration
		).from_current().set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_LINEAR)
	else:
		_start_position = position
		tween.tween_property(
			self,
			"zoom",
			Vector2(max_zoom, max_zoom),
			duration
		).from_current().set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_LINEAR)


func _on_Events_explosion_occurred() -> void:
	self.shake_amount += 0.6
