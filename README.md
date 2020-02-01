# Harvester #

Harvester is a top down space mining game. Control your spaceship in forays into an asteroid belt, gather iron, and bring it back to base. Spend them to upgrade your ship's speed and manoeuvrability and cargo space.

Beware, however; you are not alone out here. Pirate miners are out there and want to monopolize the business.

## Summary ##

The player begins with a ship at their space station in a relatively large, procedurally generated map filled with asteroids. Their job is to navigate their way to find asteroid pockets, dock with them to mine, then dock with the station to drop them off and earn an upgrade.

As they accumulate iron and score, enemy pirates spawn around asteroid pockets. This forces the player to take different paths until they are able to destroy the interlopers.

The player continues until they are overwhelmed by the mounting difficulty and growing opposition and sees how far they can go.

## Development ##

The game is meant to showcase the [GDQuest Godot Steering Toolkit](https://github.com/GDQuest/godot-steering-toolkit) while still being a fun time waster. It is a simple demo initially, built in a kind of game-jam sort of way to keep the scope from getting out of control.

## Deliverables ##

### Player controls ###

- Travel mode: A and D rotate the ship, while W and S thrust forward and back
- Precision mode: The ship automatically rotates to face the mouse while the right mouse button is held down. A, D, W and S move them left, right, up and down relative to y-up. It is slower, but more precise.
- Shooting: The ship has energy guns that can become stronger
- Docking: When approaching an asteroid or a station, the player can activate docking mode, and an AI will take over to steer them into position and lock them in place.
- Map: The player can bring up a navigation map to get a look at where asteroids are and where pirates are.

### Pirates ###

- Spawning: Every time the player deposits a certain amount of cargo in the station, pirates spawn around some of the asteroids.
- Movement: Pirates move in precision mode. They chase the player, get within weapons fire range, but don't get too close. They do avoid asteroids to not crash into them. Once out of range, they steer back to their spawn point.

### Upgrades ###

Depositing iron into the station raises a percentage bar. When it hits 100%, the player can select from a small number of upgrades: health, speed, rotation speed, cargo space, and weapons damage.

### Map ###

The map is made up of a number of asteroid pockets separated by some distance. Asteroids have a certain amount of iron in them and vanish when emptied. More asteroids can spawn on a timer to fill some of the empty gaps.