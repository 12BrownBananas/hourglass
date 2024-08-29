extends MenuSelect

@export var options: Control;
@export var item_info: HoverInfo;
@export_enum("Left", "Right") var info_alignment = 0;

var item_info_pad_value: float = 2.0;
var item_buttons: Array[Button];
var item_select_button_prefab = load("res://scenes/ui_components/item_select_button.tscn");

func add_items(item_list: Array[ItemLookup.Item]):
	for item in item_list:
		var button: ItemSelectButton = item_select_button_prefab.instantiate();
		button.icon = item._appearance._sprite;
		button.set_name_label(item.get_name());
		button.set_durability_label(item._stats._uses, item._stats._remaining_uses);
		button.set_hover_callback(show_item_info);
		button.set_unhover_callback(hide_item_info);
		
		button.focus_entered.connect(button._on_hover);
		button.focus_exited.connect(button._on_unhover);
		button.mouse_entered.connect(button._on_hover);
		button.mouse_exited.connect(button._on_unhover);
		
		item_buttons.append(button);
		_scrollbox_button_area.add_child(button);
	queue_redraw();
	
func clear_items():
	for button in item_buttons:
		remove_child(button);
	item_buttons.clear();
	queue_redraw();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_buttons = [];
	destination = out_position;

func show_item_info(button: ItemSelectButton):
	item_info.visible = true;
	var offset = -1.0 if button.position.y < get_viewport().size.y/2.0 else 1.0;
	if (info_alignment == 0):
		item_info.position = floor(options.position+button.position+Vector2(button.size.x+item_info_pad_value, offset*item_info.get_size().y/2.0));
	else:
		item_info.position = ceil(options.position+button.position-Vector2(item_info_pad_value, 0.0)-Vector2(item_info.get_size().x, offset*item_info.get_size().y/2.0));
func hide_item_info():
	item_info.visible = false;
