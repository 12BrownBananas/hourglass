extends TileMapLayer

var astar_grid: AStarGrid2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_grid()
	_update_grid_from_tilemap()
	
func _init_grid() -> void:
	astar_grid = AStarGrid2D.new()
	astar_grid.size = get_used_rect().size
	astar_grid.cell_size = tile_set.tile_size
	#Options
	astar_grid.set_default_compute_heuristic(AStarGrid2D.Heuristic.HEURISTIC_MANHATTAN);
	astar_grid.set_default_estimate_heuristic(AStarGrid2D.Heuristic.HEURISTIC_MANHATTAN);
	astar_grid.set_diagonal_mode(AStarGrid2D.DIAGONAL_MODE_NEVER);
	astar_grid.jumping_enabled = false;
	astar_grid.update();

# Look up each grid cell in our AStarGrid2D instance
# and set it to solid based on whether or not it is a wall in the game map
func _update_grid_from_tilemap() -> void:
	for i in range(astar_grid.size.x):
		for j in range(astar_grid.size.y):
			var id = Vector2i(i, j)
			if get_cell_source_id(id) >= 0:
				var tile_type = get_cell_tile_data(id).get_custom_data('tile_type')
				astar_grid.set_point_solid(Vector2i(i, j), tile_type == 'wall')
			else:
				astar_grid.set_point_solid(Vector2i(i, j), true)

func find_path(start_pos: Vector2, end_pos: Vector2) -> Array[Vector2]:
	var start_cell = Vector2i(start_pos/astar_grid.cell_size);
	var end_cell = Vector2i(end_pos/astar_grid.cell_size);
	if start_cell == end_cell or !astar_grid.is_in_boundsv(start_cell) or !astar_grid.is_in_boundsv(end_cell):
		return []
	var path = astar_grid.get_id_path(start_cell, end_cell);
	var floatPath: Array[Vector2] = []
	for p in path:
		floatPath.append(Vector2(float(p.x)*astar_grid.cell_size.x+(astar_grid.cell_size.x/2), float(p.y)*astar_grid.cell_size.y+(astar_grid.cell_size.y/2)));
	return floatPath;
