extends CharacterBody2D;
class_name Unit;

@export var animated_sprite: AnimatedSprite2D;

var occupied_tile: GameManager.GridTile;
var get_occupied_tile_callback: Callable;
var move_target: Vector2;
var spd: float = 400.0;
var path: Array[Vector2];
var viable_tiles: Array[Vector2];
var path_index: int;
var moving: bool;
var max_distance: int; #in units, not tiles (but rounds down to tiles)
var inventory: Inventory;

func _ready():
	path_index = 0;
	moving = false;
	path = [];
	viable_tiles = [];
	move_target = Vector2(position.x, position.y);
	max_distance = 128;
	inventory = Inventory.new();

func preprocess_routine() -> void:
	animated_sprite.play("default"); #override this, if you want to do more than the base processing routine

func postprocess_routine() -> void:
	pass #override this, if you want to do more than the base processing routine

func _process(_delta):
	preprocess_routine();
	if (moving):
		if (position.x != move_target.x or position.y != move_target.y):
			if (abs(position.distance_to(move_target)) > spd*_delta):
				var movement_vector = move_target-position;
				position+=movement_vector.normalized()*spd*_delta;
			else:
				position = move_target;
		elif len(path) > 0:
			if (path_index >= path.size()-1):
				occupied_tile = get_occupied_tile_callback.call(self);
				moving = false;
			path_index = min(path_index+1, path.size()-1);
			move_target = path[path_index];
	postprocess_routine();

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

func clear_occupied_tile():
	if (occupied_tile != null):
		occupied_tile.occupant = null;
	occupied_tile = null;

func set_move_path(move_path: Array[Vector2]):
	if (moving or len(move_path) <= 0):
		return;
	if (validate_path(move_path)):
		clear_occupied_tile();
		viable_tiles.clear(); #we're moving now, so we need to reset our viable tiles
		path = move_path.duplicate();
		path_index = 0;
		moving = true;
		move_target = path[path_index];

func get_move_path() -> Array[Vector2]:
	return path.duplicate();
