# Spawns the station, asteroids, and pirates when entering the game.
# Keeps track of resources available in the world and which asteroid clusters holds it,
# and spawns more when running low.
# It also signals the pirate spawner when an upgrade has been made.
class_name GameWorld
extends Node2D

# Radius of the world in pixels.
export var radius := 8000.0
# Minimum distance to place asteroids from the station.
export var asteroid_min_spawn_distance := 2000
# Minimum distance between asteroid clusters.
export var radius_around_clusters := 600.0

# Minimum amount of iron that must be added when the world spawns new asteroids.
# Used in `_spawn_asteroids`.
export var iron_amount_balance_level := 100.0
# If the amouns of iron in the world goes below this threshold, spawns new asteroids.
export var refresh_threshold_range := 25.0

# Total amount of iron currently available to mine in the world.
var iron_amount := 0.0
var _spawned_positions := []
var _world_objects := []
var _iron_clusters := {}

onready var rng := RandomNumberGenerator.new()

onready var station_spawner: StationSpawner = $StationSpawner
onready var asteroid_spawner: AsteroidSpawner = $AsteroidSpawner
onready var pirate_spawner: PirateSpawner = $PirateSpawner


func _ready() -> void:
	yield(owner, "ready")
	setup()


func setup() -> void:
	rng.randomize()
	
	Events.connect("upgrade_chosen", self, "_on_Events_upgrade_chosen")
	
	station_spawner.spawn_station(rng)
	_spawn_asteroids()
	pirate_spawner.spawn_pirate_group(rng, 0, radius, _find_largest_inoccupied_asteroid_cluster().global_position)


func remove_iron(amount: float, asteroid: Asteroid) -> void:
	iron_amount = max(iron_amount - amount, 0)
	asteroid.iron_amount -= amount

	if iron_amount < refresh_threshold_range:
		_spawn_asteroids()


# Returns the AsteroidCluster with the most iron that isn't occupied.
# If all clusters are occupied, returns `null`.
func _find_largest_inoccupied_asteroid_cluster() -> AsteroidCluster:
	var target_cluster: AsteroidCluster
	
	var target_cluster_iron_amount := -INF
	for cluster in asteroid_spawner.get_children():
		assert(cluster is AsteroidCluster)
		if cluster.is_occupied:
			continue
		if cluster.iron_amount > target_cluster_iron_amount:
			target_cluster = cluster
			target_cluster_iron_amount = cluster.iron_amount
	target_cluster.is_occupied = true
	return target_cluster


# Spawns new asteroids until there's enough resources to mine in the world.
# The target amount of resources is `iron_amount_balance_level`.
func _spawn_asteroids() -> void:
	while iron_amount < iron_amount_balance_level:
		var cluster := asteroid_spawner.spawn_asteroid_cluster(
			rng,
			radius,
			asteroid_min_spawn_distance,
			radius_around_clusters
		)
		iron_amount += cluster.iron_amount


# Spawn a new group of pirates upon getting an upgrade
func _on_Events_upgrade_chosen(_choice) -> void:
	var target_cluster := _find_largest_inoccupied_asteroid_cluster()
	if target_cluster:
		pirate_spawner.spawn_pirate_group(rng, 0, radius, target_cluster.global_position)
