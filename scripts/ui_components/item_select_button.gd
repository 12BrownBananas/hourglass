extends Button

class_name ItemSelectButton;

@export var _name_label: Label;
@export var _durability_label: Label;

var hover_callback: Callable;
var unhover_callback: Callable;

func set_name_label(name: String):
	_name_label.text = name;
func set_durability_label(max_uses: int, remaining_uses: int):
	_durability_label.text = "{remaining_uses}/{uses}".format({"remaining_uses": remaining_uses, "uses": max_uses});
func set_hover_callback(cb: Callable):
	hover_callback = cb;
func set_unhover_callback(cb: Callable):
	unhover_callback = cb;

func _on_hover():
	hover_callback.call(self);
func _on_unhover():
	unhover_callback.call();
