extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D

func _process(_delta):
	_animated_sprite.play("default");
func set_cursor_visible(visible_status: bool):
	_animated_sprite.visible = visible_status
