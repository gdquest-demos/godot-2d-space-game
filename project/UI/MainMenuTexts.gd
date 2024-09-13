extends Control

const EXPOSE_DURATION := 2.0
const FADE_DURATION := 0.5

@onready var container := $HBoxContainer/CenterContainer
@onready var tween := create_tween()
@onready var keyboard := container.get_node("AnyKey")
@onready var xbox := container.get_node("XboxA")
@onready var playstation := container.get_node("PlaystationX")
@onready var nintendo := container.get_node("NintendoB")

@onready var elements := [keyboard, xbox, playstation, nintendo]


func _ready() -> void:
	var total_time := 0.0
	for element in elements:
		total_time += _fade_in(element, total_time)
		total_time += _fade_out(element, total_time)
	tween.set_loops()
	tween.play()


func _fade_in(target: Control, total_time: float) -> float:
	tween.tween_property(
		target,
		"modulate",
		Color.WHITE,
		FADE_DURATION
	).from(Color.TRANSPARENT).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	return FADE_DURATION


func _fade_out(target: Control, total_time: float) -> float:
	tween.tween_property(
		target,
		"modulate",
		Color.TRANSPARENT,
		FADE_DURATION
	).from(Color.WHITE).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	return FADE_DURATION + EXPOSE_DURATION
