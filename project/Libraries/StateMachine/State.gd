# State interface to use in Hierarchical State Machines.
# The lowest leaf tries to handle callbacks, and if it can't, it delegates the work to its parent.
# It's up to the user to call the parent state's functions, e.g. `_parent.physics_process(delta)`
# Use State as a child of a StateMachine node.
# tags: abstract
extends Node
class_name State

onready var _state_machine := _get_state_machine(self)
var _parent: State = null


func _ready() -> void:
	yield(owner, "ready")
	_parent = get_parent() as State


func unhandled_input(_event: InputEvent) -> void:
	pass


func physics_process(_delta: float) -> void:
	pass


func enter(_msg: Dictionary = {}) -> void:
	pass


func exit() -> void:
	pass


func _get_state_machine(node: Node) -> Node:
	if node != null and not node.is_in_group("state_machine"):
		return _get_state_machine(node.get_parent())
	return node
