extends ItemSelect;
class_name ItemDiscardSelect;

@export var new_label: Label;
@export var background: ColorRect;
@export var pre_new_item_pad_value: float;

var dialog_prompt_fstring = "Discard {obj}?"

func populate(item_list: Array[ItemLookup.Item], new_item: ItemLookup.Item) -> void:
	add_items(item_list);
	insert_pad();
	add_items([new_item]);
	resize();

func additional_setup():
	pressed_callback = show_discard_dialog;

func resize() -> void:
	var height = _header_label.position.y+_header_label.size.y+_scrollbox_button_area.size.y;
	background.size.y = height;

func insert_pad() -> void:
	_scrollbox_button_area.move_child(new_label, len(_scrollbox_button_area.get_children()))

func clear_items():
	for button in item_buttons:
		_scrollbox_button_area.remove_child(button);
	item_buttons.clear();
	queue_redraw();

func show_discard_dialog(caller: ItemSelectButton):
	dialog_box.set_prompt(dialog_prompt_fstring.format({"obj": caller._name_label.text}));
	dialog_box.visible = true;
