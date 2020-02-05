extends Camera2D


export var elastic_strength := 0.1

var player: Node2D


func _ready() -> void:
	_set_player()
	
	ObjectRegistry.connect(
		"registry_group_changed",
		self,
		"_on_RegistryGroup_registry_group_changed"
	)


func _physics_process(delta: float) -> void:
	if player:
		global_position = (
				global_position.linear_interpolate(player.global_position, elastic_strength)
		)


func _set_player():
	if ObjectRegistry.has_group("Player"):
		var player_group := ObjectRegistry.get_nodes_from_group("Player")
		player = player_group[0]
	else:
		player = null


func _on_RegistryGroup_registry_group_changed(group: String) -> void:
	if group == "Player":
		_set_player()
