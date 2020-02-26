extends Control


const FADE_IN_TIME := 0.5
const FADE_OUT_TIME := 2.5

var _transitioning := false

onready var tween := $Tween
onready var fadeout := $FadeOut

func _ready() -> void:
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


func _unhandled_input(event: InputEvent) -> void:
	if not _transitioning:
		if event is InputEventKey or event.is_action_pressed("thrust_forwards"):
			_transitioning = true
			tween.interpolate_property(
				fadeout,
				"modulate",
				Color.transparent,
				Color.white,
				FADE_OUT_TIME,
				Tween.TRANS_LINEAR,
				Tween.EASE_OUT
			)
			tween.start()
			yield(tween, "tween_all_completed")
			get_tree().change_scene("res://src/Game.tscn")
