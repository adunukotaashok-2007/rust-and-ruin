extends Node2D

@export var map_width: int = 100
@export var map_height: int = 100
@export var tile_size: int = 32

enum TileType { GRASS, DIRT, WATER, SAND, FOREST, ROCK }

var world_map: Array = []
var noise: FastNoiseLite

func _ready():
    generate_world()

func generate_world():
    noise = FastNoiseLite.new()
    noise.seed = randi()
    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
    noise.frequency = 0.05
    
    world_map.clear()
    
    for x in range(map_width):
        var row = []
        for y in range(map_height):
            var value = noise.get_noise_2d(x, y)
            var tile = get_tile_from_noise(value)
            row.append(tile)
        world_map.append(row)
    
    print("🌍 World generated: %dx%d tiles" % [map_width, map_height])

func get_tile_from_noise(value: float) -> int:
    if value < -0.3:
        return TileType.WATER
    elif value < -0.15:
        return TileType.SAND
    elif value < 0.2:
        return TileType.GRASS
    elif value < 0.4:
        return TileType.FOREST
    elif value < 0.6:
        return TileType.DIRT
    else:
        return TileType.ROCK

func get_tile_at(x: int, y: int) -> int:
    if x >= 0 and x < map_width and y >= 0 and y < map_height:
        return world_map[x][y]
    return TileType.WATER
