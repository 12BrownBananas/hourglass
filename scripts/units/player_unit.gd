extends Unit;
class_name PlayerUnit;

func revert_move_path() -> void:
	if len(path) > 0:
		viable_tiles.clear(); #we're moving now, so we need to reset our viable tiles
		path_index = 0;
		move_target = path[path_index];
		position = move_target;
		moving = false;
