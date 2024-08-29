extends Node2D

class_name MenuBase;

@export var in_position: Vector2;
@export var out_position: Vector2;
@export_range(0.0, 1.0) var lerp_factor: float;

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
