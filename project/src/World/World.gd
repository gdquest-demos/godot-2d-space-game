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
	station_spawner.spawn_station()
	_spawn_asteroids()
	Events.connect(
		"upgrade_choice_made", pirate_spawner, "spawn_pirate_group", [radius, self]
	)
	pirate_spawner.spawn_pirate_group(0, radius, self)


func remove_iron(amount: float, asteroid: Node2D) -> void:
	iron_amount = max(iron_amount - amount, 0)
	_remove_cluster_iron(amount, asteroid)

	if iron_amount < refresh_threshold_range:
		_spawn_asteroids()


# Returns the position of the cluster of asteroids with the most iron 
# that isn't occupied by pirates.
func find_freshest_iron_cluster() -> Vector2:
	var largest_cluster: float = -INF
	var largest_position := Vector2.ZERO
	for cluster_position in _iron_clusters.keys():
		var cluster: Dictionary = _iron_clusters[cluster_position]
		if not cluster.occupied and cluster.iron_amount > largest_cluster:
			largest_cluster = cluster.iron_amount
			largest_position = cluster_position
			cluster.occupied = true

	if largest_cluster == -INF:
		largest_position = (
			Vector2.UP.rotated(rng.randf_range(-PI, PI))
			* radius
			* rng.randf_range(0.5, 1)
		)
	return largest_position


# Spawns new asteroids until there's enough resources to mine in the world.
# The target amount of resources is `iron_amount_balance_level`.
func _spawn_asteroids() -> void:
	Events.connect("asteroid_cluster_spawned", self, "_on_Spawner_spawned_asteroid_cluster")
	while iron_amount < iron_amount_balance_level:
		asteroid_spawner.spawn_random_cluster(
			radius,
			_spawned_positions,
			asteroid_min_spawn_distance,
			radius_around_clusters,
			self
		)


func _remove_cluster_iron(amount: float, asteroid: Node2D) -> void:
	for cluster_position in _iron_clusters.keys():
		var cluster = _iron_clusters[cluster_position]
		for a in cluster.asteroids:
			if a == asteroid:
				cluster.iron_amount -= amount
				if cluster.iron_amount <= 0:
					_iron_clusters.erase(cluster_position)
					return


func _on_Spawner_spawned_asteroid_cluster(asteroids: Array) -> void:
	var cluster_position := Vector2.ZERO
	var iron_amount_local := 0

	for asteroid in asteroids:
		iron_amount += asteroid.iron_amount
		iron_amount_local += asteroid.iron_amount
		cluster_position += asteroid.global_position

	cluster_position /= asteroids.size()

	_iron_clusters[cluster_position] = {
		iron_amount = iron_amount_local, asteroids = asteroids, occupied = false
	}
