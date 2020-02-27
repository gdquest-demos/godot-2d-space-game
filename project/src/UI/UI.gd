extends CanvasLayer

onready var screen_fader: TextureRect = $ScreenFader


func _ready() -> void:
	Events.connect("player_died", self, "_on_Player_died")
	screen_fader.fade_in()


func _on_Player_died(is_delayed: bool) -> void:
	screen_fader.fade_out(is_delayed)
	yield(screen_fader, "animation_finished")
	get_tree().change_scene("res://src/UI/MainMenu.tscn")
