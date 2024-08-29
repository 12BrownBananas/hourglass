extends Node2D

@export var player: CharacterBody2D;
@export var cursor: CharacterBody2D;
@export var zone: Rect2;

@onready var exp_bar = $ExpBar;

var player_is_nearby: bool = false;
var player_was_nearby: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (player_was_nearby != player_is_nearby):
		player_was_nearby = player_is_nearby;
		exp_bar.toggle();
	player_is_nearby = zone.has_point(player.position) or zone.has_point(cursor.position);
