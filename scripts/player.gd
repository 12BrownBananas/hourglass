extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D

var move_target: Vector2;
var spd: float = 400.0;
var path: Array[Vector2];
var viable_tiles: Array[Vector2];
var path_index: int;
var moving: bool;
var max_distance: int; #in units, not tiles (but rounds down to tiles)

func _ready():
	path_index = 0;
	moving = false;
	path = [];
	viable_tiles = [];
	move_target = Vector2(position.x, position.y);
	max_distance = 128;

func _process(_delta):
	_animated_sprite.play("default");
	if (moving):
		if (position.x != move_target.x or position.y != move_target.y):
			if (abs(position.distance_to(move_target)) > spd*_delta):
				var movement_vector = move_target-position;
				position+=movement_vector.normalized()*spd*_delta;
			else:
				position = move_target;
		elif len(path) > 0:
			if (path_index >= path.size()-1):
				moving = false;
			path_index = min(path_index+1, path.size()-1);
			move_target = path[path_index];

func validate_path(move_path: Array[Vector2]):
	var dist = 0;
	var last = null;
	var curr = null;
	for i in move_path:
		if (last == null):
			last = i;
		else:
			curr = i;
			dist += (last-curr).length();
			last = curr;
	return dist <= max_distance;

func probe_tile(path_to_tile: Array[Vector2]) -> void:
	if (len(path_to_tile) <= 0): 
		return;
	if (validate_path(path_to_tile)):
		viable_tiles.append(path_to_tile[len(path_to_tile)-1]);

func get_tile_is_viable(tile: Vector2) -> bool:
	for i in viable_tiles:
		if (i.x == tile.x and i.y == tile.y):
			return true;
	return false;

func set_move_path(move_path: Array[Vector2]):
	if (moving or len(move_path) <= 0):
		return;
	if (validate_path(move_path)):
		viable_tiles.clear(); #we're moving now, so we need to reset our viable tiles
		path = move_path.duplicate();
		path_index = 0;
		moving = true;
		move_target = path[path_index];

func get_move_path() -> Array[Vector2]:
	return path.duplicate();

func revert_move_path() -> void:
	if len(path) > 0:
		viable_tiles.clear(); #we're moving now, so we need to reset our viable tiles
		path_index = 0;
		move_target = path[path_index];
		position = move_target;
		moving = false;
