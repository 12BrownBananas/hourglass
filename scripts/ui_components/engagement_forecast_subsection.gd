extends Node2D;
class_name EngagementForecastSubsection;

@export var stats_readout: VBoxContainer;

var dimensions: Vector2;

func _ready() -> void:
	var w = (stats_readout.position.x+stats_readout.size.x)-position.x;
	var h = (stats_readout.position.y+stats_readout.size.y)-position.y;
	dimensions = Vector2(w, h);
