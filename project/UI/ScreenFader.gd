# Animates a black screen that covers the entire screen - keeps transitions
# from simply going menu-game or game-menu in an abrupt and jarring way.
extends TextureRect

signal animation_finished

@export var duration_fade_in := 0.5
@export var duration_fade_out := 2.5

var is_playing := false

var tween : Tween


# Animate from the current modulate color until the node is fully transparent.
func fade_in() -> void:
	tween = create_tween()
	tween.finished.connect(_on_Tween_tween_completed)
	tween.tween_property(
		self,
		"modulate",
		Color.TRANSPARENT,
		duration_fade_in
	).from_current().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	show()
	tween.play()
	is_playing = true


# Animate from the current modulate color until the node is fully black.
func fade_out(is_delayed: bool = false) -> void:
	tween = create_tween()
	tween.finished.connect(_on_Tween_tween_completed)
	tween.tween_property(
		self,
		"modulate",
		Color.WHITE,
		duration_fade_out
	).from_current().set_delay(duration_fade_out if is_delayed else 0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	show()
	tween.play()
	is_playing = true


func _on_Tween_tween_completed() -> void:
	animation_finished.emit()
	if modulate == Color.TRANSPARENT:
		hide()
	is_playing = false
