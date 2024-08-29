extends Node2D
class_name Submenu;

@export var button_area: VBoxContainer;
@export var background: ColorRect;
var button_prefab = load("res://scenes/ui_components/context_sensitive_menu_button.tscn");
var buttons: Array[Button];

class OptionConfig:
	var name: String;
	var callback: Callable;
	func _init(button_name: String, button_callback: Callable):
		name = button_name;
		callback = button_callback;

func set_buttons(options: Array[OptionConfig]):
	clear_buttons();
	var height = 0.0;
	var i = 0;
	var pad_value = 4.0;
	for o in options:
		var b = button_prefab.instantiate();
		b.label.text = o.name;
		b.callback = o.callback;
		buttons.append(b);
		button_area.add_child(b);
		height = height+b.size.y;
		if (i > 0):
			height+=pad_value;
		i = i+1;
	resize(Vector2(button_area.size.x, button_area.position.y+height));;
	
func resize(new_size: Vector2):
	background.size.y = new_size.y;

func clear_buttons():
	for b in buttons:
		button_area.remove_child(b);
	buttons.clear();
		
