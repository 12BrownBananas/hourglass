extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D

var moveTarget: Vector2;
var spd: float = 100.0;
var path: Array[Vector2];
var pathIndex: int;

func _ready():
	pathIndex = 0;
	path = [];
	moveTarget = Vector2(position.x, position.y);

func _process(_delta):
	_animated_sprite.play("default");
	if (position.x != moveTarget.x or position.y != moveTarget.y):
		if (abs(position.distance_to(moveTarget)) > spd*_delta):
			var movementVector = moveTarget-position;
			position+=movementVector.normalized()*spd*_delta;
		else:
			position = moveTarget;
	elif len(path) > 0:
		pathIndex = min(pathIndex+1, path.size()-1);
		moveTarget = path[pathIndex];

func set_move_path(movePath: Array[Vector2]):
	if (len(movePath) <= 0):
		return;
	path = movePath.duplicate();
	pathIndex = 0;
	moveTarget = path[pathIndex];
