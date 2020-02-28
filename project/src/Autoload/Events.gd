extends Node

signal player_died
signal quit_requested

signal station_spawned(station, player)
signal pirate_spawned(pirate)
signal asteroid_spawned(object)
signal cluster_spawned(object)

signal map_toggled(is_visible, animation_length)

signal upgrade_unlocked()
signal upgrade_choice_made(choice)

signal damaged(target, damage, shooter)

signal begin_patrol(squad_leader)
signal end_patrol(squad_leader)
signal reached_cluster(squad_leader)
signal squad_leader_changed(old_leader, new_leader, current_patrol_point)
signal target_aggroed(squad_leader, target)
signal call_off_pursuit(squad_leader)

signal force_undock
signal docked
signal undocked

enum UpgradeChoices { HEALTH, SPEED, CARGO, MINING, WEAPON }

enum UITypes { UPGRADE, QUIT }
