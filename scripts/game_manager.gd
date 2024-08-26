extends Node2D

@onready var _player = $Player;
@onready var _tilemap = $TileMap;
@onready var _cursor = $Cursor;

const sceneDimensions = Vector2i(480, 270);
const tileSize = 16;
var gridSize;
var gridMap;

class GridTile:
	var position;
	func _init(x: float, y: float):
		position = Vector2(x, y);

func _input(event):
	var closestTile = get_closest_tile(get_viewport().get_mouse_position());
	_cursor.position.x = closestTile.position.x;
	_cursor.position.y = closestTile.position.y;
	
	if event is InputEventMouseButton:
		if (event.pressed):
			_player.set_move_path(_tilemap.find_path(_player.position, _cursor.position));

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var xGrid = floor(sceneDimensions.x/tileSize+.99);
	var yGrid = floor(sceneDimensions.y/tileSize+.99);
	gridMap = []
	for i in range(xGrid):
		gridMap.append([]);
		for j in range(yGrid):
			gridMap[i].append(GridTile.new(i*tileSize+tileSize/2, j*tileSize+tileSize/2));
	
func get_closest_tile(position: Vector2) -> GridTile:
	var currX = clamp(floor(((position.x-tileSize/2)/tileSize)+0.5), 0.0, len(gridMap)-1);
	var currY = clamp(floor(((position.y-tileSize/2)/tileSize)+0.5), 0.0, len(gridMap[currX])-1);
	return gridMap[currX][currY];

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()

func _draw():
	for i in gridMap:
		for j in i:
			var dx = j.position.x-tileSize/2;
			var dy = j.position.y-tileSize/2;
			draw_rect(Rect2(dx, dy, dx+tileSize, dy+tileSize), Color.DARK_GRAY, false);
