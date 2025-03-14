class_name ItemLookup;

enum ItemCategory { SLASH, PIERCE, BLUNT, MAGIC }

class Item:
	var _name: String;
	var _category: ItemCategory
	var _stats: ItemStats;
	var _appearance: ItemAppearance;
	var _effects: Array[ItemEffect];
	func _init(name: String, category: ItemCategory, stats: ItemStats, appearance: ItemAppearance, effects: Array[ItemEffect] = []):
		_name = name;
		_category = category;
		_stats = stats;
		_appearance = appearance;
		_effects = effects;
	func get_name():
		return _name;
	func check_viable_range(range: int):
		for r in _stats._ranges:
			if (range == r):
				return true;
		return false;
	func duplicate() -> Item:
		var effectsCopy: Array[ItemEffect] = []
		for i in _effects:
			effectsCopy.append(i.duplicate());
		return Item.new(_name, _category, _stats.duplicate(), _appearance.duplicate(), effectsCopy);
	func get_power() -> int:
		return _stats.get_power();
	func get_crit_chance() -> int:
		return _stats.get_crit_chance();
	func get_accuracy() -> int:
		return _stats.get_accuracy();

class ItemStats:
	var _uses: int;
	var _remaining_uses: int
	var _power: int;
	var _ranges: Array[int];
	var _accuracy: float;
	var _crit_chance: float;
	var _aoe: Array[Vector2]; #contains relative coordinates influenced by the use of this item
	func _init(uses: int, power: int, accuracy: float, crit_chance: float, ranges: Array[int], aoe: Array[Vector2] = []):
		_uses = uses;
		_remaining_uses = _uses;
		_power = power;
		_accuracy = accuracy;
		_crit_chance = crit_chance;
		_ranges = ranges;
		_aoe = aoe;
	func duplicate() -> ItemStats:
		return ItemStats.new(_uses, _power, _accuracy, _crit_chance, _ranges.duplicate(), _aoe.duplicate());
	func get_power() -> int:
		return _power;
	func get_accuracy() -> int:
		return _accuracy;
	func get_crit_chance() -> int:
		return _crit_chance;

class ItemAppearance:
	var _sprite: Texture2D;
	func _init(sprite: Texture2D):
		_sprite = sprite;
	func duplicate() -> ItemAppearance:
		return ItemAppearance.new(_sprite);

class ItemEffect: #some placeholder definition for additional item behavior
	func duplicate() -> ItemEffect:
		return ItemEffect.new();

var lookup: Array[Item];

func _init(icon_lookup: IconLookup):
	lookup = []
	
	lookup.append(Item.new("Bronze Sword", ItemCategory.SLASH, ItemStats.new(10, 1, 1.0, 0.1, [1]), ItemAppearance.new(icon_lookup.item_icons[0])));
	lookup.append(Item.new("Bow", ItemCategory.PIERCE, ItemStats.new(5, 1, 1.0, 0.1, [2]), ItemAppearance.new(icon_lookup.item_icons[1])));
	lookup.append(Item.new("Hand Axe", ItemCategory.SLASH, ItemStats.new(7, 1, 0.8, 0.2, [1, 2]), ItemAppearance.new(icon_lookup.item_icons[2])));

func get_item(item_index: int) -> Item:
	if (item_index < 0 or item_index > len(lookup)-1):
		print("WARNING: Item index %s is out of range!" % item_index);
	return lookup[clamp(item_index, 0.0, len(lookup)-1)].duplicate();

func get_item_by_name(item_name: String) -> Item:
	for i in lookup:
		if i.get_name() == item_name:
			return i;
	print("WARNING: Item with name %s not found!" %item_name);
	return lookup[0].duplicate();
