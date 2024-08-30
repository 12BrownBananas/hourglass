class_name EnemyLookup;

class Enemy:
	var name: String;
	var stats: EnemyStats;
	var appearance: EnemyAppearance;
	func _init(enemy_name: String, stat: EnemyStats, aspect: EnemyAppearance):
		name = enemy_name;
		stats = stat;
		appearance = aspect;
	func duplicate():
		return Enemy.new(name, stats, appearance);

class EnemyStats:
	var hp: int;
	var current_hp: int;
	var movement: int;
	func _init(max_hp: int, movement_range: int):
		hp = max_hp;
		current_hp = hp;
		movement = movement_range;
	func duplicate():
		return EnemyStats.new(hp, movement);

class EnemyAppearance:
	var _sprite: Texture2D;
	func _init(sprite: Texture2D):
		_sprite = sprite;
	func duplicate() -> EnemyAppearance:
		return EnemyAppearance.new(_sprite);

var lookup: Array[Enemy];

func _init(sprite_lookup: EnemySpriteLookup):
	lookup = []
	lookup.append(Enemy.new("Keese", EnemyStats.new(3, 5), EnemyAppearance.new(sprite_lookup.enemy_sprites[0])));

func get_enemy(enemy_index: int) -> Enemy:
	if (enemy_index < 0 or enemy_index > len(lookup)-1):
		print("WARNING: Enemy index %s is out of range!" % enemy_index);
	return lookup[clamp(enemy_index, 0.0, len(lookup)-1)].duplicate();

func get_enemy_by_name(enemy_name: String) -> Enemy:
	for i in lookup:
		if i.get_name() == enemy_name:
			return i;
	print("WARNING: Enemy with name %s not found!" %enemy_name);
	return lookup[0].duplicate();
