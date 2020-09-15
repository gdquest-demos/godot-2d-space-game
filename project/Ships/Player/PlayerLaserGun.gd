# LaserGun that fires based on user's input

extends LaserGun

export var fire_action := "fire2"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action(fire_action):
		self.is_firing = event.is_pressed()
