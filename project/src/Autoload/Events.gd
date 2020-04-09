# Autoloaded singleton that holds signals that would be troublesome to wire in a
# local parent or a scene owner.
# 
# This keeps objects passed through setup functions or unsafe accessors at a
# lower count, and can be replaced with simpler `Events.connect` calls.
extends Node

signal player_died
signal quit_requested

signal node_spawned(node)
signal station_spawned(station, player)
signal pirate_spawned(pirate)
signal asteroid_spawned(object)
signal asteroid_cluster_spawned(object)

signal map_toggled(is_visible, animation_length)

signal upgrade_unlocked
signal upgrade_choice_made(choice)

signal damaged(target, damage, shooter)

signal begin_patrol(squad_leader)
signal end_patrol(squad_leader)
signal reached_cluster(squad_leader)
signal squad_leader_changed(old_leader, new_leader, current_patrol_point)
signal target_aggroed(squad_leader, target)
signal call_off_pursuit(squad_leader)

signal force_undock
signal docked(docking_point)
signal undocked
signal mine_started(mine_position)
signal mine_finished

signal explosion_occurred

enum UpgradeChoices { HEALTH, SPEED, CARGO, MINING, WEAPON }

enum UITypes { UPGRADE, QUIT }
