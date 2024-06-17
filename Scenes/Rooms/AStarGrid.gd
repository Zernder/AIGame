extends TileMap

var astar = AStarGrid2D.new()
@onready var player = $"../Player"

var tilemapsize = get_used_rect().end - get_used_rect().position
var maprect = Rect2i(Vector2i.ZERO, tilemapsize)
var tilesize = get_tileset().tile_size



func _ready():
	SetupGrid()



func SetupGrid():
	astar.region = maprect
	astar.cell_size = tilesize
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	for x in tilemapsize.x:
		for y in tilemapsize.y:
			var tilepos = Vector2i(x, y)
			var tiledata = get_cell_tile_data(0, tilepos)
			if tiledata and tiledata.get_custom_data('Type') == "Wall":
					astar.set_point_solid(tilepos)
			var posgrid = tilepos / 16



