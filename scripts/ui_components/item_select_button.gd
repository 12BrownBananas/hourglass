extends Button

class_name ItemSelectButton;

@export var _name_label: Label;
@export var _durability_label: Label;

func set_name_label(name: String):
	_name_label.text = name;
func set_durability_label(max_uses: int, remaining_uses: int):
	_durability_label.text = "{remaining_uses}/{uses}".format({"remaining_uses": remaining_uses, "uses": max_uses});
