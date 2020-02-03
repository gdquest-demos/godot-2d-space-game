extends Node2D


export var Projectile: PackedScene

var cooling_down := false

onready var projectile_parent: Node = get_tree().get_nodes_in_group("Projectiles")[0]
onready var cooldown := $Cooldown


func _ready() -> void:
	cooldown.connect("timeout", self, "_on_Cooldown_timeout")


func fire(spawn_position: Vector2, spawn_orientation: float, projectile_mask: int) -> void:
	if cooling_down or not Projectile:
		return
	
	var projectile: Node2D = Projectile.instance()
	projectile.global_position = spawn_position
	projectile.rotation = spawn_orientation
	projectile.collision_mask = projectile_mask
	
	projectile_parent.add_child(projectile)
	cooling_down = true
	cooldown.start()


func _on_Cooldown_timeout() -> void:
	cooling_down = false
