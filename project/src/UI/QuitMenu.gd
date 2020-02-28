# Presents a confirmation screen whether the player really intends on leaving
# the game back to the main menu or not.
extends MarginContainer

onready var yes_button := $VBoxContainer/HBoxContainer/YesButton
onready var no_button := $VBoxContainer/HBoxContainer/NoButton


func _ready() -> void:
	visible = false
	set_process_input(false)
	yes_button.connect("button_down", self, "request_quit")
	no_button.connect("button_down", self, "close")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close()
		get_tree().set_input_as_handled()


func open() -> void:
	get_tree().paused = true
	show()
	no_button.grab_focus()
	set_process_input(true)


func close() -> void:
	get_tree().paused = false
	set_process_input(false)
	hide()


func request_quit() -> void:
	Events.emit_signal("quit_requested")
	close()
