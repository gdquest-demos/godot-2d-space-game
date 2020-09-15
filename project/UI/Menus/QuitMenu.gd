# Presents a confirmation screen whether the player really intends on leaving
# the game back to the main menu or not.
extends MarginContainer

onready var yes_button := $VBoxContainer/HBoxContainer/YesButton
onready var no_button := $VBoxContainer/HBoxContainer/NoButton
onready var menu_sounds: MenuSoundPlayer = $MenuSoundPlayer


func _ready() -> void:
	visible = false
	set_process_input(false)
	for button in [yes_button, no_button]:
		button.connect("focus_entered", self, "_on_Button_focus_entered")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close()
		get_tree().set_input_as_handled()


func open() -> void:
	get_tree().paused = true
	menu_sounds.play_open()
	show()
	no_button.grab_focus()
	set_process_input(true)


func close() -> void:
	menu_sounds.play_close()
	get_tree().paused = false
	set_process_input(false)
	hide()


func request_quit() -> void:
	Events.emit_signal("quit_requested")
	close()


func _on_YesButton_pressed() -> void:
	request_quit()


func _on_NoButton_pressed() -> void:
	close()


func _on_Button_focus_entered() -> void:
	menu_sounds.play_hide()
