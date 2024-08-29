extends MenuBase;

class_name EnemyInformation;

@export var in_position_left: Vector2;
@export var out_position_left: Vector2;
@export var in_position_right: Vector2;
@export var out_position_right: Vector2;

@export var drop_area: Control;
@export var drop_button: Button;
@export var item_info: HoverInfo;
@export_enum("Left", "Right") var info_alignment = 0;

var item_info_pad_value = 4.0;
var on_default_side: bool = true;

func jump_left() -> void:
	on_default_side = true;
	jump();
	
func jump_right() -> void:
	on_default_side = false;
	jump();
	
func jump() -> void:
	in_view = false;
	if (on_default_side):
		position = out_position_left;
		out_position = out_position_left;
		in_position = in_position_left;
	else:
		position = out_position_right;
		out_position = out_position_right;
		in_position = in_position_right;
	destination = position;

func _ready() -> void:
	destination = out_position;
	
	drop_button.focus_entered.connect(show_item_info);
	drop_button.focus_exited.connect(hide_item_info);
	drop_button.mouse_entered.connect(show_item_info);
	drop_button.mouse_exited.connect(hide_item_info);

func show_item_info() -> void:
	item_info.visible = true;
	var offset = -1.0 if drop_area.position.y < get_viewport().size.y/2.0 else 1.0;
	if (info_alignment == 0):
		item_info.position = floor(position+drop_area.position+drop_button.position+Vector2(drop_button.size.x+item_info_pad_value, offset*item_info.get_size().y/2.0));
	else:
		item_info.position = ceil(position+drop_area.position-Vector2(item_info_pad_value, 0.0)-Vector2(item_info.get_size().x, offset*item_info.get_size().y/2.0));
func hide_item_info() -> void:
	item_info.visible = false;
