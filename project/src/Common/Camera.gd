extends Camera2D


export var elastic_strength := 0.1

var player: Node2D


func _physics_process(delta: float) -> void:
	global_position = global_position.linear_interpolate(
			player.global_position,
			elastic_strength
	)


func setup_player(player: Node2D) -> void:
	if player:
		player.connect("died", self, "_on_Player_died")
	self.player = player
	if not player:
		set_physics_process(false)
	else:
		set_physics_process(true)


func _on_Player_died() -> void:
	setup_player(null)
