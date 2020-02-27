extends CanvasLayer

onready var screen_fader: TextureRect = $ScreenFader
onready var map: TextureRect = $MapDisplay
onready var quit_menu := $QuitMenu

func _ready() -> void:
	Events.connect("player_died", self, "quit", [true])
	Events.connect("quit_requested", self, "quit", [false])
	screen_fader.fade_in()


func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:
		return

	if event.is_action_pressed("ui_cancel"):
		quit_menu.open()
	if event.is_action_pressed("toggle_map") and not map.is_animating():
		map.toggle()


func quit(with_delay: bool) -> void:
	screen_fader.fade_out(with_delay)
	yield(screen_fader, "animation_finished")
	get_tree().change_scene("res://src/UI/MainMenu.tscn")
