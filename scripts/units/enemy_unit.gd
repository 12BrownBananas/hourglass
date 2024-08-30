extends Unit;
class_name EnemyUnit;

var description: EnemyLookup.Enemy;

func set_description(desc: EnemyLookup.Enemy):
	description = desc;
	animated_sprite.sprite_frames = description.appearance._sprite;
