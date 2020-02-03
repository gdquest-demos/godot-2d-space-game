extends KinematicBody2D


export(int, LAYERS_2D_PHYSICS) var projectile_mask := 0

var can_dock := false

onready var shape := $CollisionShape
onready var agent: GSTSteeringAgent = $StateMachine/Move.agent
