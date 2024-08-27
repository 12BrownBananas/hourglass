extends Node2D

@onready var _player = $Player;
@onready var _tilemap = $TileMap;
@onready var _cursor = $Cursor;
@onready var _path_forecast = $PathForecast;

const scene_dimensions = Vector2i(480, 270);
const tile_size = 16;
var grid_size;
var grid_map;

class GridTile:
	var position;
	func _init(x: float, y: float):
		position = Vector2(x, y);

func _input(event):
	var closestTile = get_closest_tile(get_viewport().get_mouse_position());
	_cursor.position.x = closestTile.position.x;
	_cursor.position.y = closestTile.position.y;
	
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
			_player.set_move_path(_tilemap.find_path(_player.position, _cursor.position));
		elif (event.button_index == MOUSE_BUTTON_RIGHT and event.pressed):
			_player.revert_move_path();
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var xgrid = floor(scene_dimensions.x/tile_size+.99);
	var ygrid = floor(scene_dimensions.y/tile_size+.99);
	grid_map = []
	for i in range(xgrid):
		grid_map.append([]);
		for j in range(ygrid):
			grid_map[i].append(GridTile.new(i*tile_size+tile_size/2, j*tile_size+tile_size/2));
	
func get_closest_tile(position: Vector2) -> GridTile:
	var currx = clamp(floor(((position.x-tile_size/2)/tile_size)+0.5), 0.0, len(grid_map)-1);
	var curry = clamp(floor(((position.y-tile_size/2)/tile_size)+0.5), 0.0, len(grid_map[currx])-1);
	return grid_map[currx][curry];

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (_player.get_tile_is_viable(_cursor.position)):
		_path_forecast.points = PackedVector2Array(_tilemap.find_path(_player.position, _cursor.position));
	else:
		_path_forecast.clear_points();
	
	if (_player.moving == false and len(_player.viable_tiles) <= 0):
		#recalculate viable tiles for the player
		_player.viable_tiles.append(_player.position);
		for i in grid_map:
			for j in i:
				_player.probe_tile(_tilemap.find_path(_player.position, j.position));
	queue_redraw()
func _draw():
	for i in grid_map:
		for j in i:
			var dx = j.position.x-tile_size/2;
			var dy = j.position.y-tile_size/2;
			draw_rect(Rect2(dx, dy, tile_size, tile_size), Color.DARK_GRAY, false);
	if (!_player.moving):
		for i in _player.viable_tiles:
			var dx = i.x-tile_size/2;
			var dy = i.y-tile_size/2;
			draw_rect(Rect2(dx, dy, tile_size, tile_size), Color(0.0, 0.0, 1.0, 0.25), true);
