# Autoloaded singleton that takes care of spawning and caching instances of
# one-shot particle emitters. This keeps them from generating too much garbage
# to be cleaned up by the engine, as we can re-use them per-template instead.
extends Node

var emitters := {}


func get_new_emitter(template: PackedScene) -> Particles2D:
	if not emitters.has(template):
		emitters[template] = []
	var emitter_cache: Array = emitters[template]
	if emitter_cache.size() > 0:
		return emitter_cache.pop_front()
	else:
		var out_emitter: Particles2D = template.instance()
		out_emitter.cache = self
		out_emitter.template = template
		return out_emitter


func recycle_emitter(emitter: Particles2D, template: PackedScene) -> void:
	emitter.emitting = false
	emitter.get_parent().remove_child(emitter)
	emitters[template].append(emitter)
