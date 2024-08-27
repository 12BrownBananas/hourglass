extends Node2D;

class_name Inventory;

var items: Array[ItemLookup.Item]

func _ready() -> void:
	items = []
func add_items(item_list: Array[ItemLookup.Item]):
	if (len(item_list) > 0):
		items.append_array(item_list);
func get_item(item_index: int):
	return items[item_index];
