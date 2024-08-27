extends Node2D

var agrid: AStarGrid2D
@onready var tile_map = $TileMap


func  _ready():
	agrid = AStarGrid2D.new()
	agrid.region = tile_map.get_used_rect()
	agrid.cell_size = Vector2(16,16)
	agrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	agrid.update()
	print(agrid.cell_size)
	print(agrid.region)


func _input(event):
	var idpath = agrid.get_id_path(
		tile_map.local_to_map(global_position),
		tile_map.local_to_map(get_global_mouse_position())
	)
	print(idpath)
