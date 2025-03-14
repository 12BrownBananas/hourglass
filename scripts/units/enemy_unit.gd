extends Unit;
class_name EnemyUnit;

var description: EnemyLookup.Enemy;

func set_description(desc: EnemyLookup.Enemy):
	description = desc;
	animated_sprite.sprite_frames = description.appearance._sprite;
	
	hp = description.stats.current_hp;
	max_hp = description.stats.hp;
	max_distance = description.stats.movement;

func path_to_player():
	pass
