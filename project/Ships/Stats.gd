# Virtual base class for stats (health, speed...) that support upgrades.
#
# You must call `initialize()` to initialize the stats' values. This ensures that they are in sync
# with the values modified in Godot's inspector.
#
# Each stat should be a floating point value, and we recommend to make them private properties, as
# they should be read-only. To get a stat's calculated value, with modifiers, see `get_stat()`.
class_name Stats
extends Resource

signal stat_changed(stat, old_value, new_value)

# Stores a cached array of property names that are stats as strings, that we use to find and
# calculate the stats with upgrades from the base stats.
var _stats_list := _get_stats_list()
# Modifiers has a list of modifiers for each property in `_stats_list`. A modifier is a dict that
# requires a key named `value`. The value of a modifier can be positive or negative.
var _modifiers := {}
# Stores the cached values for the computed stats
var _cache := {}


# Initializes the keys in the modifiers dict, ensuring they all exist, without going through the
# property's setter.
func _init() -> void:
	for stat in _stats_list:
		_modifiers[stat] = []
		_cache[stat] = 0.0


# Call this function from your node's ready function, before accessing the stats. This ensures
# they're all loaded.
func initialize() -> void:
	_update_all()


# Get the final value of a stat, with all modifiers applied to it.
func get_stat(stat_name := "") -> float:
	assert(stat_name in _stats_list)
	return _cache[stat_name]


# Adds a modifier to the stat corresponding to `stat_name` and returns the new modifier's id.
func add_modifier(stat_name: String, modifier: float) -> int:
	assert(stat_name in _stats_list)
	_modifiers[stat_name].append(modifier)
	_update(stat_name)
	return len(_modifiers)


# Removes a modifier from the stat corresponding to `stat_name`.
func remove_modifier(stat_name: String, id: int) -> void:
	assert(stat_name in _stats_list)
	_modifiers[stat_name].erase(id)
	_update(stat_name)


# Removes the last modifier applied the stat corresponding to `stat_name`.
func pop_modifier(stat_name: String) -> void:
	assert(stat_name in _stats_list)
	_modifiers[stat_name].pop_back()
	_update(stat_name)


# Remove all modifiers and recalculate stats.
func reset() -> void:
	_modifiers = {}
	_update_all()


# Calculates the final value of a single stat, its based value with all modifiers applied.
func _update(stat: String = "") -> void:
	var value_start: float = self.get(_stats_list[stat])
	var value = value_start
	for modifier in _modifiers[stat]:
		value += modifier
	_cache[stat] = value
	emit_signal("stat_changed", stat, value_start, value)


# Recalculates every stat from the base stat, with modifiers.
func _update_all() -> void:
	for stat in _stats_list:
		_update(stat)


# Returns a list of stat properties as strings.
func _get_stats_list() -> Dictionary:
	var ignore := [
		"resource_local_to_scene",
		"resource_name",
		"resource_path",
		"script",
		"_stats_list",
		"_modifiers",
		"_cache"
	]
	var stats := {}
	for p in get_property_list():
		if p.name[0].capitalize() == p.name[0]:
			continue
		if p.name in ignore:
			continue
		stats[p.name.lstrip("_")] = p.name
	return stats
