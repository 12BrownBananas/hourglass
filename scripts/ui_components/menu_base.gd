extends Node2D

class_name MenuBase;

@export var in_position: Vector2;
@export var out_position: Vector2;
@export_range(0.0, 1.0) var lerp_factor: float = .25;

var destination: Vector2;
var in_view: bool = false;

func additional_toggle_processing() -> void: #override this
	pass

func toggle_in() -> void:
	destination = out_position if in_view else in_position;
	in_view = !in_view;
	additional_toggle_processing()
func force_out() -> void:
	destination = out_position;
	in_view = false;
func force_in() -> void:
	destination = in_position;
	in_view = true;
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	destination = out_position;

func update_position(_delta: float):
	position += (destination-position)*lerp_factor;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_position(_delta);
