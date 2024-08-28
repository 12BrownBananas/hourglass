extends Node2D

class_name MenuSelect;

@export var in_position = Vector2(0.0, 0.0);
@export var out_position = Vector2(190.0, 0.0);
@export_range(0.0, 1.0) var lerp_factor: float = 0.25;
@export var xpad = 4;
@export var _header_label: Label;
@export var _scrollbox : ScrollContainer;
@export var _scrollbox_button_area: VBoxContainer;

var buttons: Array[Button];
var destination: Vector2;
var in_view: bool = false;

func toggle_in() -> void:
	destination = out_position if in_view else in_position;
	in_view = !in_view;
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	destination = out_position;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position += (destination-position)*lerp_factor;
	if (abs(destination-position) < Vector2(0.01, 0.01)):
		destination = position;
	
func _draw() -> void:
	var box_height = _header_label.get_combined_minimum_size().y+_scrollbox.size.y;
	var box_width = _scrollbox.size.x+xpad;
	var t = _header_label.get_transform().get_origin();
	var dx = t.x-xpad/2.0;
	var dy = t.y;
	draw_rect(Rect2(dx, dy, box_width, box_height), Color(0.0, 0.0, 0.0, 0.5), true); 
