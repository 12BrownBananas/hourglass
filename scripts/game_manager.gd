extends Node2D

class_name GameManager;

@export var debug_enemy: EnemyUnit;
var highlighted_enemy: EnemyUnit = null;
@export var player: PlayerUnit;

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
@onready var _target_select = $Scene/HUD/TargetSelect;
@onready var _enemy_information = $Scene/HUD/EnemyInformation;

#State variables for target selection
#Note that these should probably be moved out of the game manager super-module at some point.
var locked_on: bool = false;
var target_select_mode: bool = false;

var item_lookup: ItemLookup;
var enemy_lookup: EnemyLookup;
const scene_dimensions = Vector2i(480, 270);
const tile_size = 16;
var grid_map: Array[GridMapRow];
var action_stack: Array[Callable];

class GridMapRow:
	var row: Array[GridTile]
	func _init():
		row = []

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
	var occupant: Unit;
	func _init(x: float, y: float):
		position = Vector2(x, y);
		occupant = null;

func wait_callback():
	print("Wait pressed");
	
func attack_callback():
	_target_select.force_in();
	_cursor.set_cursor_visible(true);
	_action_select.force_out();
	action_stack.push_front(_revert_open_target_select);
	target_select_mode = true;

func _revert_open_target_select():
	_cursor.set_cursor_visible(false);
	#_action_select.force_in();
	_target_select.force_out();
	target_select_mode = false;
	hide_enemy_information();
	_undo_previous_action();

func open_engagement_forecast(target: EnemyUnit):
	_engagement_forecast.force_in();
	target_select_mode = false;
	locked_on = true;
	action_stack.push_front(_revert_open_engagement_forecast);

func _revert_open_engagement_forecast():
	_engagement_forecast.force_out();
	locked_on = false;
	target_select_mode = true;

func open_action_select_menu(unit: Unit):
	_action_select.clear_actions();
	var action_list: Array[PlayerAction] = [];
	#attempt to populate action select menu with context sensitive actions
	var can_attack = populate_context_sensitive_actions(action_list);
	action_list.append(PlayerAction.new("Wait", Callable(self, "wait_callback")));
	_action_select.add_actions(action_list);
	if (can_attack):
		#_action_select.toggle_in();
		attack_callback(); #let's just skip right to the attack stage, if it's viable
	else:
		_action_select.toggle_in();
	
func close_action_select_menu():
	_action_select.force_out();

func populate_context_sensitive_actions(action_list: Array[PlayerAction]) -> bool:
	var viable: bool = _player.check_viability_at_range(get_tile_distance_between_positions(_player.position, debug_enemy.position));
	if (viable):
		action_list.append(PlayerAction.new("Attack", Callable(self, "attack_callback")));
	return viable;

func show_enemy_information(enemy_unit: EnemyUnit):
	if (!_enemy_information.in_view):
		#note that get_viewport.size returns in gui coordinates, whereas mouse position is in 2D coordinates.
		if get_viewport().get_mouse_position().x < 240.0: #get_viewport().size.x/2:
			_enemy_information.jump_left();
		else:
			_enemy_information.jump_right();
		_enemy_information.toggle_in();
func hide_enemy_information():
	_enemy_information.force_out();
	highlighted_enemy = null;

func enemy_check_routine(closest_tile: GridTile):
	var inspecting_enemy = false;
	#this should be in a list comprehension of all enemies, but for now...
	if (debug_enemy.occupied_tile == closest_tile):
		highlighted_enemy = debug_enemy;
		show_enemy_information(highlighted_enemy);
		inspecting_enemy = true;
	if (!inspecting_enemy):
		hide_enemy_information();

func _input(event):
	if (!locked_on):
		var closest_tile = get_closest_tile(get_viewport().get_mouse_position());
		_cursor.position.x = closest_tile.position.x;
		_cursor.position.y = closest_tile.position.y;
		if (target_select_mode):
			enemy_check_routine(closest_tile);
	
	if event is InputEventKey:
		if (event.pressed):
			if (event.keycode == KEY_1):
				open_action_select_menu(_player);
			if (event.keycode == KEY_2):
				_target_select.toggle_in();
				#_item_select.toggle_in();
			if (event.keycode == KEY_3):
				_engagement_forecast.toggle_in();
			if (event.keycode == KEY_4):
				_enemy_information.toggle_in();
			if (event.keycode == KEY_5):
				_item_discard_select.toggle_in();
			if (event.keycode == KEY_6):
				var closest_viable_tile = get_closest_tile(debug_enemy.position).position;
				var player_tile = get_closest_tile(player.position).position;
				for tile in debug_enemy.viable_tiles: #remember to adjust player's position coordinate to the center of the sprite
					var dist_vector = (player_tile-tile);
					var prev_vector = (player_tile-closest_viable_tile);
					if (dist_vector.length() < prev_vector.length()):
						closest_viable_tile = tile;
					elif (dist_vector.length() == prev_vector.length()):
						if (debug_enemy.position-tile).length() < (debug_enemy.position-closest_viable_tile).length():
							closest_viable_tile = tile;
				debug_enemy.set_move_path(_tilemap.find_path(debug_enemy.position, closest_viable_tile));
				
	
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
			if (!target_select_mode):
				if _player.get_tile_is_viable(_cursor.position):
					_player.set_move_path(_tilemap.find_path(_player.position, _cursor.position));
					_cursor.set_cursor_visible(false);
					action_stack.push_front(_revert_player_move_path);
			else:
				if (highlighted_enemy != null):
					_enemy_information.force_out();
					open_engagement_forecast(highlighted_enemy);
		elif (event.button_index == MOUSE_BUTTON_RIGHT and event.pressed):
			_undo_previous_action();

func _revert_player_move_path():
	close_action_select_menu();
	_player.revert_move_path();
	_cursor.set_cursor_visible(true);
func _undo_previous_action():
	if (action_stack.is_empty()):
		return;
	action_stack.pop_front().call();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#initialize grid
	var xgrid = floor(scene_dimensions.x/float(tile_size)+.99);
	var ygrid = floor(scene_dimensions.y/float(tile_size)+.99);
	grid_map = []
	for i in range(xgrid):
		grid_map.append(GridMapRow.new());
		for j in range(ygrid):
			grid_map[i].row.append(GridTile.new(i*float(tile_size)+float(tile_size)/2.0, j*tile_size+tile_size/2.0));
			
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
	
	debug_enemy.set_description(enemy_lookup.get_enemy(0));
	
	#position player and enemy
	player.set_occupied_tile_callback = set_occupied_tile;
	player.path_complete_callback = open_action_select_menu;
	var player_tile = get_closest_tile(player.position);
	player.position = player_tile.position;
	player.occupied_tile = player_tile;
	player_tile.occupant = player;
	
	var enemy_tile = get_closest_tile(debug_enemy.position);
	debug_enemy.position = enemy_tile.position;
	enemy_tile.occupant = debug_enemy;
	debug_enemy.occupied_tile = enemy_tile;
	debug_enemy.set_occupied_tile_callback = set_occupied_tile;
	
func set_occupied_tile(unit: Unit) -> GridTile:
	#this is a callback function
	var occupied_tile = get_closest_tile(unit.position);
	unit.position = occupied_tile.position;
	occupied_tile.occupant = unit;
	
	update_navmesh_with_unit_positions();
	
	#note that it's probably more efficient to do this just before a move
	_player.viable_tiles.clear();
	debug_enemy.viable_tiles.clear();
	
	return occupied_tile;

func update_navmesh_with_unit_positions() -> void:
	var unit_array: Array[Unit] = [player, debug_enemy];#should actually just be a list of all units
	_tilemap.update_grid_from_unit_positions(unit_array, tile_size); 

func convert_position_to_tile_coordinates(pos: Vector2):
	var currx = clamp(floor(((pos.x-tile_size/2.0)/tile_size)+0.5), 0.0, len(grid_map)-1);
	var curry = clamp(floor(((pos.y-tile_size/2.0)/tile_size)+0.5), 0.0, len(grid_map[currx].row)-1);
	
	return Vector2(currx, curry);

func get_tile_distance_between_positions(pos1: Vector2, pos2: Vector2) -> int:
	var unit1_tile_coord = convert_position_to_tile_coordinates(pos1);
	var unit2_tile_coord = convert_position_to_tile_coordinates(pos2);
	
	return abs(unit1_tile_coord.x-unit2_tile_coord.x)+abs(unit1_tile_coord.y-unit2_tile_coord.y);

func get_closest_tile(pos: Vector2) -> GridTile:
	var tile_coord = convert_position_to_tile_coordinates(pos);
	return grid_map[tile_coord.x].row[tile_coord.y];

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (_player.get_tile_is_viable(_cursor.position)):
		_path_forecast.points = PackedVector2Array(_tilemap.find_path(_player.position, _cursor.position));
	else:
		_path_forecast.clear_points();
	
	if (_player.moving == false and _player.can_move and len(_player.viable_tiles) <= 0):
		#recalculate viable tiles for the player
		_player.viable_tiles.append(_player.position);
		for i in grid_map:
			for j in i.row:
				if j.occupant == null:
					_player.probe_tile(_tilemap.find_path(_player.position, j.position));
				
	if (debug_enemy.moving == false and len(debug_enemy.viable_tiles) <= 0):
		debug_enemy.viable_tiles.append(debug_enemy.position);
		for i in grid_map:
			for j in i.row:
				if j.occupant == null:
					debug_enemy.probe_tile(_tilemap.find_path(debug_enemy.position, j.position));
	queue_redraw()
func _draw():
	for i in grid_map:
		for j in i.row:
			var dx = j.position.x-tile_size/2.0;
			var dy = j.position.y-tile_size/2.0;
			draw_rect(Rect2(dx, dy, tile_size, tile_size), Color.DARK_GRAY, false);
	if (!_player.moving && _player.can_move):
		for i in _player.viable_tiles:
			var dx = i.x-tile_size/2.0;
			var dy = i.y-tile_size/2.0;
			draw_rect(Rect2(dx, dy, tile_size, tile_size), Color(0.0, 0.0, 1.0, 0.25), true);
	if (!debug_enemy.moving && _player.can_move):
		var closest_tile = get_closest_tile(get_viewport().get_mouse_position());
		if (debug_enemy.occupied_tile == closest_tile):
			for i in debug_enemy.viable_tiles:
				var dx = i.x-tile_size/2.0;
				var dy = i.y-tile_size/2.0;
				draw_rect(Rect2(dx, dy, tile_size, tile_size), Color(1.0, 0.0, 0.0, 0.25), true);
	#var item = _player.inventory.get_item(0)
	#draw_texture(item._appearance._sprite, _player.position+Vector2(0.0, -12.0));
