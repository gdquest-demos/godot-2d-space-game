extends Node2D


export var Projectile: PackedScene

var cooling_down := false
var projectile_parent: Node2D

onready var cooldown := $Cooldown


func _ready() -> void:
	var parents = get_tree().get_nodes_in_group("Projectiles")
	if parents.size() > 0:
		projectile_parent = parents[0]
	
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
