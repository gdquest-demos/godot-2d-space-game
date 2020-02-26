extends CanvasLayer


const FADE_IN_TIME := 0.5
const FADE_OUT_TIME := 2.5

var transitioning := false

onready var tween := $Tween
onready var fadeout := $FadeOut


func _ready() -> void:
	Events.connect("player_died", self, "_on_Player_died")
	tween.interpolate_property(
		fadeout,
		"modulate",
		Color.white,
		Color.transparent,
		FADE_IN_TIME,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT
	)
	tween.start()


func _on_Player_died(delayed: bool) -> void:
	tween.interpolate_property(
		fadeout,
		"modulate",
		Color.transparent,
		Color.white,
		FADE_OUT_TIME,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT,
		FADE_OUT_TIME if delayed else 0
	)
	tween.start()
	transitioning = true
	yield(tween, "tween_all_completed")
	get_tree().change_scene("res://src/UI/MainMenu.tscn")
