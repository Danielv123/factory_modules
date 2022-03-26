# Factory modules

Massive modular factories without cheats or UPS issues

## Why

Factorio allows you to build bases that grow forever. Eventually you reach the dreaded UPS limit. Once that happens, you have to look into your options:

1. Mods that make entities produce more (feels like cheating)

2. Mods that attempt to hide the low UPS by increasing speeds

3. Scaling to multiple computers (clusterio)

This mod is designed to be a 4th option. It aims to allow groups of vanilla entities to be deactivated to not consume clock cycles while still producing.
Gameplay should still feel vanilla - builds will have the same footprints, ratios, number of entities in their construction and designs.

## How

To start you create a border around a rectangular area with stone walls. This is your primary production area.
Resources are only allowed to move in and out through the wall using loaders and chests.
By blueprinting the area you can create clones of it. The clones won't simulate the movement of the internal entities, but will sync their input and output with the primary production area.

Each area is called a `module`. A module keeps track of all the wall, chest and combinator entities it consists of. When a wall entity is destroyed the module breaks.

The module ID is stored in a constant combinator. ID namespaces are seperate for each size of modules. One module is declared the "primary" module - it is the only module that is simulated by the game engine. Entities are mirrored to "secondary" modules as ghosts. Secondary modules are only "active" when they contain no ghosts.

## Setup

`mklink /D C:\Users\danielv\AppData\Roaming\Factorio\mods\factory_modules C:\Users\danielv\Documents\project_files\factory_modules`
