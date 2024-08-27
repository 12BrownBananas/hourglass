extends Node2D

@export_range(0.0, 1.0) var lerp_factor: float = 0.25;

@onready var _item_scrollbox = $ItemSelectOptions;
@onready var _item_scrollbox_buttons = $ItemSelectOptions/VBoxContainer;
@onready var _header_label = $Header;

var item_buttons: Array[Button];
var item_select_button_prefab = load("res://scenes/ui_components/item_select_button.tscn");
const xpad = 4;

var destination: Vector2;

const in_position = Vector2(0.0, 0.0);
const out_position = Vector2(190.0, 0.0);
var in_view: bool = false;

func add_items(item_list: Array[ItemLookup.Item]):
	for item in item_list:
		var button: ItemSelectButton = item_select_button_prefab.instantiate();
		button.icon = item._appearance._sprite;
		button.set_name_label(item.get_name());
		button.set_durability_label(item._stats._uses, item._stats._remaining_uses);
		item_buttons.append(button);
		_item_scrollbox_buttons.add_child(button);
	queue_redraw();
	
func clear_items():
	for button in item_buttons:
		remove_child(button);
	item_buttons.clear();
	queue_redraw();

func toggle_in() -> void:
	destination = out_position if in_view else in_position;
	in_view = !in_view;
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_buttons = [];
	destination = out_position;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += (destination-position)*lerp_factor;
	if (abs(destination-position) < Vector2(0.01, 0.01)):
		destination = position;
	
func _draw() -> void:
	var it = _item_scrollbox.size;
	var box_height = _header_label.get_combined_minimum_size().y+_item_scrollbox.size.y;
	var box_width = _item_scrollbox.size.x+xpad;
	var t = _header_label.get_transform().get_origin();
	var dx = t.x-xpad/2;
	var dy = t.y;
	draw_rect(Rect2(dx, dy, box_width, box_height), Color(0.0, 0.0, 0.0, 0.5), true); 
