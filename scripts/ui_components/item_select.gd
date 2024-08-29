extends MenuSelect;
class_name ItemSelect;

@export var options: Control;
@export var item_info: HoverInfo;
@export var context_sensitive_menu: Submenu;
@export var dialog_box: DialogBox;
@export_enum("Left", "Right") var info_alignment = 0;

var item_info_pad_value: float = 2.0;
var item_buttons: Array[Button];
var item_select_button_prefab = load("res://scenes/ui_components/item_select_button.tscn");
var hover_button: ItemSelectButton;
var pressed_callback: Callable;

func add_items(item_list: Array[ItemLookup.Item]):
	for item in item_list:
		var button: ItemSelectButton = item_select_button_prefab.instantiate();
		button.icon = item._appearance._sprite;
		button.set_name_label(item.get_name());
		button.set_durability_label(item._stats._uses, item._stats._remaining_uses);
		button.set_hover_callback(show_item_info);
		button.set_unhover_callback(hide_item_info);
		button.set_pressed_callback(pressed_callback);
		
		button.focus_entered.connect(button._on_hover);
		button.focus_exited.connect(button._on_unhover);
		button.mouse_entered.connect(button._on_hover);
		button.mouse_exited.connect(button._on_unhover);
		
		button.pressed.connect(button._on_pressed);
		
		item_buttons.append(button);
		_scrollbox_button_area.add_child(button);
	queue_redraw();
	
func clear_items():
	for button in item_buttons:
		_scrollbox_button_area.remove_child(button);
	item_buttons.clear();
	queue_redraw();

func additional_setup():
	pressed_callback = show_context_sensitive_menu;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_buttons = [];
	destination = out_position;
	additional_setup();
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_position(_delta);
	if (item_info.visible):
		realign_item_info();

func additional_toggle_processing() -> void: #override this
	if (!in_view and item_info.visible):
		hide_item_info();

func get_submenu_position(submenu_size: Vector2) -> Vector2:
	var offset = -1.0 if hover_button.position.y < get_viewport().size.y/2.0 else 1.0;
	if (info_alignment == 0):
		return floor(position+options.position+_scrollbox.position+hover_button.position+Vector2(hover_button.size.x+item_info_pad_value, 0.0));
	else:
		return ceil(position+options.position+_scrollbox.position+hover_button.position-Vector2(item_info_pad_value, 0.0)-Vector2(submenu_size.x, 0.0));

func realign_item_info():
	if (hover_button == null):
		return;
	item_info.position = get_submenu_position(item_info.get_size());

func show_item_info(button: ItemSelectButton):
	item_info.visible = true;
	hover_button = button;
	realign_item_info();
	
func hide_item_info():
	item_info.visible = false;
	
func show_context_sensitive_menu(caller: Button):
	hide_item_info();
	#first populate the menu with the appropriate buttons, based on the current context
	var op: Array[Submenu.OptionConfig] = [];
	var do_nothing = Submenu.OptionConfig.new("Do Nothing", hide_context_sensitive_menu);
	op.append(do_nothing);
	context_sensitive_menu.set_buttons(op);
	
	#now show the menu
	context_sensitive_menu.position = get_submenu_position(context_sensitive_menu.background.size);
	context_sensitive_menu.visible = true;

func hide_context_sensitive_menu():
	context_sensitive_menu.visible = false;
