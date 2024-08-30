extends Node2D

class_name GameManager;

#data components
@onready var _icon_lookup = $Data/IconLookup;
@onready var _enemy_sprite_lookup = $Data/EnemySpriteLookup;
#scene components
@onready var _player = $Scene/Player;
@onready var _tilemap = $Scene/TileMap;
@onready var _cursor = $Scene/Cursor;
@onready var _path_forecast = $Scene/PathForecast;
#@onready var _hud = $Scene/HUD;
@onready var _item_select = $Scene/HUD/ItemSelect;
@onready var _item_discard_select = $Scene/HUD/ItemDiscardSelect;
@onready var _action_select = $Scene/HUD/ActionSelect;
@onready var _engagement_forecast = $Scene/HUD/EngagementForecast;
@onready var _enemy_information = $Scene/HUD/EnemyInformation;

var item_lookup: ItemLookup;
var enemy_lookup: EnemyLookup;
const scene_dimensions = Vector2i(480, 270);
const tile_size = 16;
var grid_size;
var grid_map;

class PlayerAction:
	var _name: String;
	var _callback: Callable;
	func _init(name: String, callback: Callable):
		_name = name;
		_callback = callback;
	func get_name():
		return _name;
	func invoke():
		_callback.call();

class GridTile:
	var position;
	func _init(x: float, y: float):
		position = Vector2(x, y);

func wait_callback():
	print("Wait pressed");

func _input(event):
	var closestTile = get_closest_tile(get_viewport().get_mouse_position());
	_cursor.position.x = closestTile.position.x;
	_cursor.position.y = closestTile.position.y;
	
	if event is InputEventKey:
		if (event.pressed):
			if (event.keycode == KEY_1):
				_action_select.clear_actions();
				var action_list: Array[PlayerAction] = [];
				action_list.append(PlayerAction.new("Wait", Callable(self, "wait_callback")));
				_action_select.add_actions(action_list);
				_action_select.toggle_in();
			if (event.keycode == KEY_2):
				_item_select.toggle_in();
			if (event.keycode == KEY_3):
				_engagement_forecast.toggle_in();
			if (event.keycode == KEY_4):
				if (!_enemy_information.in_view):
					#note that get_viewport.size returns in gui coordinates, whereas mouse position is in 2D coordinates.
					if get_viewport().get_mouse_position().x < 240.0:#get_viewport().size.x/2:
						_enemy_information.jump_left();
					else:
						_enemy_information.jump_right();
				_enemy_information.toggle_in();
			if (event.keycode == KEY_5):
				_item_discard_select.toggle_in();
				
	
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
			_player.set_move_path(_tilemap.find_path(_player.position, _cursor.position));
		elif (event.button_index == MOUSE_BUTTON_RIGHT and event.pressed):
			_player.revert_move_path();
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#initialize grid
	var xgrid = floor(scene_dimensions.x/float(tile_size)+.99);
	var ygrid = floor(scene_dimensions.y/float(tile_size)+.99);
	grid_map = []
	for i in range(xgrid):
		grid_map.append([]);
		for j in range(ygrid):
			grid_map[i].append(GridTile.new(i*float(tile_size)+float(tile_size)/2.0, j*tile_size+tile_size/2.0));
			
	#initialize player inventory
	item_lookup = ItemLookup.new(_icon_lookup);
	var init_list: Array[ItemLookup.Item] = [];
	init_list.append(item_lookup.get_item(1));
	init_list.append(item_lookup.get_item(0));
	init_list.append(item_lookup.get_item(2));
	init_list.append(item_lookup.get_item(1));
	_player.inventory.add_items(init_list);
	
	#initialize enemy compendium
	enemy_lookup = EnemyLookup.new(_enemy_sprite_lookup);
	
	#test synchronizing player inventory with item select box
	_item_select.add_items(_player.inventory.items);
	var test_new = item_lookup.get_item(1);
	_item_discard_select.populate(_player.inventory.items, test_new);
	
func get_closest_tile(pos: Vector2) -> GridTile:
	var currx = clamp(floor(((pos.x-tile_size/2.0)/tile_size)+0.5), 0.0, len(grid_map)-1);
	var curry = clamp(floor(((pos.y-tile_size/2.0)/tile_size)+0.5), 0.0, len(grid_map[currx])-1);
	return grid_map[currx][curry];

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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
			var dx = j.position.x-tile_size/2.0;
			var dy = j.position.y-tile_size/2.0;
			draw_rect(Rect2(dx, dy, tile_size, tile_size), Color.DARK_GRAY, false);
	if (!_player.moving):
		for i in _player.viable_tiles:
			var dx = i.x-tile_size/2.0;
			var dy = i.y-tile_size/2.0;
			draw_rect(Rect2(dx, dy, tile_size, tile_size), Color(0.0, 0.0, 1.0, 0.25), true);
	#var item = _player.inventory.get_item(0)
	#draw_texture(item._appearance._sprite, _player.position+Vector2(0.0, -12.0));
