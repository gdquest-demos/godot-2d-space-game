# Changelog

This document lists the new features, improvements, changes, and bug fixes in each new release of the Godot 2D Space game Harvester.

## Harvester: 2D Space Game 1.0.0

## New Features

- Visual redesign: new asteroids, animated star field in the background, and more.
- New visual effects:
    - Shockwave when accelerating and docking (deformation shader).
    - Animated docking area to indicate when you can safely dock onto an asteroid or the station.
    - Ship movement trail.
- Redesigned Heads-Up Display.
    - Animated shield bar.
    = Animated mining, with ore that goes from asteroids to the UI, and vice-versa when unloading in the station.

## Changes

- Updated QuitMenu to quit the game instead of reseting to the main menu.
- Refactored the mini-map's code to remove coupling.
- Simplified some code, renamed variables for clarity.

## Bug fixes

- Fixed an error with a nonexistent stat when getting a weapon upgrade.

## Harvester: 2D Space Game 0.1.0

### Features

This first release brings the full base game loop, with a controllable ship, mining, pirate squads, upgrades, and more.

Includes:

- An animated mini-map (<kbd>M</kbd> to toggle the map).
- AI formations, with flocks of agents following a leader. They stay out of each-other's way.
- Deformation shader, you can see it when firing plasma balls (<kbd>Space</kbd>).
- High-performance glow shader, used for the plasma balls.
