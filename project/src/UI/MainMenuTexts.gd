extends CenterContainer

const EXPOSE_DURATION := 2.0
const FADE_DURATION := 0.5

onready var tween := $Tween
onready var keyboard := $Keyboard
onready var xbox := $Xbox
onready var playstation := $Playstation
onready var nintendo := $Nintendo

onready var texts := [keyboard, xbox, playstation, nintendo]


func _ready() -> void:
	var total_time := 0.0
	for text in texts:
		total_time += _fade_in(text, total_time)
		total_time += _fade_out(text, total_time)
	tween.start()


func _fade_out(target: RichTextLabel, total_time: float) -> float:
	tween.interpolate_property(
		target,
		"modulate",
		Color.white,
		Color.transparent,
		FADE_DURATION,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT,
		total_time + EXPOSE_DURATION
	)
	return FADE_DURATION + EXPOSE_DURATION


func _fade_in(target: RichTextLabel, total_time: float) -> float:
	tween.interpolate_property(
		target,
		"modulate",
		Color.transparent,
		Color.white,
		FADE_DURATION,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT,
		total_time
	)
	return FADE_DURATION
