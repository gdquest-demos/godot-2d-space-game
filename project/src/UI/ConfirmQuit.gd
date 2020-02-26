extends MarginContainer


var _is_focused := false

onready var yes := $VBoxContainer/HBoxContainer/Yes
onready var no := $VBoxContainer/HBoxContainer/No


func _ready() -> void:
	yes.connect("button_down", self, "_on_Yes_down")
	no.connect("button_down", self, "_on_No_down")


func _unhandled_input(event: InputEvent) -> void:
	if _is_focused and event.is_action_pressed("ui_cancel"):
		_on_No_down()


func focus() -> void:
	$VBoxContainer/HBoxContainer/No.grab_focus()


func _on_Yes_down() -> void:
	Events.emit_signal("player_died", false)
	_on_No_down()


func _on_No_down() -> void:
	_is_focused = false
	visible = false
	Events.emit_signal("ui_removed")
