extends Node

enum event_type{ITEM, OBSTACLE, ENEMY, NONE}
enum property{FOOD, BRITTLE}
const GRID_RESOLUTION:int = 12
const GRID_SIZE:int = 600
const TILE_SIZE:int = GRID_SIZE/GRID_RESOLUTION
