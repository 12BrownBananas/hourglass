extends CharacterBody2D;
class_name Unit;

@export var animated_sprite: AnimatedSprite2D;

var hp: int;
var max_hp: int;
var equipped_item: ItemLookup.Item;
var occupied_tile: GameManager.GridTile;
var set_occupied_tile_callback: Callable;
var path_complete_callback: Callable;
var move_target: Vector2;
var spd: float = 400.0;
var path: Array[Vector2];
var viable_tiles: Array[Vector2];
var path_index: int;
var moving: bool;
var can_move: bool;
var max_distance: int; #in units, not tiles (but rounds down to tiles)
var inventory: Inventory;

class FlashEffect extends Node2D:
	var intensity: float = 1.0;
	var flash_timer: float = 0.0;
	var flash_duration: float = 0.05;
	var timer: float = 0.0;
	var lifetime: float = 0.3;
	var conclude_event: Callable;
	func _init(_conclude_event: Callable):
		conclude_event = _conclude_event;
	func _process(_delta: float):
		flash_timer+=_delta;
		timer+=_delta;
		if (flash_timer >= flash_duration):
			flash_timer-=flash_duration;
			if (intensity == 0.0):
				intensity = 1.0;
			else:
				intensity = 0.0;
		if (timer >= lifetime):
			conclude_event.call();
			call_deferred("free");

class ShakeEffect extends Node2D:
	var offset: Vector2;
	var timer: float;
	var duration: float;
	var intensity: float;
	var conclude_event: Callable;
	var direction: float = 0.0;
	var destination: Vector2;
	var shake_rate: float = 2.0; #2 frames per shake destination
	var wait: bool = false;
	var shake_spd: Vector2;
	func _init(_shake_intensity: float, _shake_duration: float, _conclude_event: Callable):
		intensity = _shake_intensity;
		duration = _shake_duration;
		conclude_event = _conclude_event;
		timer = 0.0;
		offset = Vector2(0.0, 0.0);
		direction = 359.9*randf();
		destination = Vector2(intensity*cos(deg_to_rad(direction)), intensity*sin(deg_to_rad(direction)));
		shake_spd = (destination-offset)/shake_rate;
		wait = true;
	func _process(_delta: float):
		timer += _delta;
		var percent_complete = 1.0-(timer/duration);
		if (wait):
			offset += shake_spd;
			if (abs(offset-destination) < abs(shake_spd)):
				direction -= 180.0;
				direction += 90.0*(randf()-0.5);
				if (direction < 0):
					direction+=360.0;
				if (direction > 360.0):
					direction-=360.0;
				destination = Vector2(intensity*percent_complete*cos(deg_to_rad(direction)), intensity*percent_complete*sin(deg_to_rad(direction)));
				shake_spd = (destination-offset)/shake_rate;
		if (timer >= duration):
			conclude_event.call();
			call_deferred("free");

var shake_effect: ShakeEffect;
var flash_effect: FlashEffect;

func _ready():
	path_index = 0;
	moving = false;
	can_move = true;
	path = [];
	viable_tiles = [];
	move_target = Vector2(position.x, position.y);
	max_distance = 128;
	inventory = Inventory.new();
	
func add_item(item: ItemLookup.Item) -> void:
	if (inventory.items.size() <= 0):
		equipped_item = item;
	inventory.add_items([item]);
func add_items(items: Array[ItemLookup.Item]):
	if (inventory.items.size() <= 0 && items.size() > 0):
		equipped_item = items[0];
	inventory.add_items(items);
func equip_item(item_index: int):
	equipped_item = inventory.get_item(item_index);

func preprocess_routine() -> void:
	animated_sprite.play("default"); #override this, if you want to do more than the base processing routine

func process_effects() -> void:
	if (flash_effect != null):
		animated_sprite.material.set_shader_parameter("flash_intensity", flash_effect.intensity);
	
	if (shake_effect != null):
		animated_sprite.position.x = shake_effect.offset.x;
		animated_sprite.position.y = shake_effect.offset.y;

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
				occupied_tile = set_occupied_tile_callback.call(self);
				moving = false;
				#path is now complete, so we can advance to the next "stage" in our turn.
				path_complete_callback.call(self);
			path_index = min(path_index+1, path.size()-1);
			move_target = path[path_index];
	
	process_effects();
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
		if (len(move_path) <= 0):
			viable_tiles.clear();
			can_move = false;
			path = move_path.duplicate();
			path_complete_callback.call(self);
			move_target = position;
		return;
	if (validate_path(move_path)):
		clear_occupied_tile();
		viable_tiles.clear(); #we're moving now, so we need to reset our viable tiles
		path = move_path.duplicate();
		path_index = 0;
		moving = true;
		can_move = false;
		move_target = path[path_index];

func get_move_path() -> Array[Vector2]:
	return path.duplicate();
	
func check_viability_at_range(distance_to_target: int) -> bool:
	for item in inventory.items:
		if (item.check_viable_range(distance_to_target)):
			return true;
	return false

func calculate_damage(target: Unit) -> int:
	if (equipped_item == null):
		return 0;
	var base_dmg = equipped_item.get_power();
	#for now, this is enough-- we're doing flat damage
	return base_dmg;

func calculate_hit_chance(target: Unit) -> int:
	if (equipped_item == null):
		return 0;
	var base_hit_chance = equipped_item.get_accuracy();
	#for now, this is enough-- no fancy hit chance calculations (yet)!
	return base_hit_chance;

func calculate_crit_chance(target: Unit) -> int:
	if (equipped_item == null):
		return 0;
	var base_crit_chance = equipped_item.get_crit_chance();
	#for now, this is enough-- we'll save adding modifiers to crit chance for later
	return base_crit_chance;
	
func calculate_number_of_attacks(target: Unit) -> int:
	return 1; #simple for now

func unregister_flash_effect() -> void:
	animated_sprite.material.set_shader_parameter("flash_intensity", 0.0);
	flash_effect = null;
func unregister_shake_effect() -> void:
	animated_sprite.position.x = 0.0;
	animated_sprite.position.y = 0.0;
	shake_effect = null;
func trigger_flash_and_shake() -> void:
	flash_effect = FlashEffect.new(unregister_flash_effect);
	add_child(flash_effect);
	shake_effect = ShakeEffect.new(5.0, 0.5, unregister_shake_effect);
	add_child(shake_effect);
