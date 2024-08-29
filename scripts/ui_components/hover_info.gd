extends Node2D
class_name HoverInfo;

@export var stats_container: Control;
@export var description: ColorRect;

func get_size() -> Vector2:
	return Vector2(max(stats_container.size.x, description.size.x), stats_container.size.y+description.size.y);
