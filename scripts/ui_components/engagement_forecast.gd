extends MenuBase;
class_name EngagementForecast;

@export var left_component: EngagementForecastSubsection;
@export var right_component: EngagementForecastSubsection;
@export var drop_area: Control;
@export var drop_button: Button;
@export var item_info: HoverInfo;
@export var weapon_select: Button;
@export_enum("Left", "Right") var info_alignment = 0;

var item_info_pad_value = 4.0;

class EngagementInfo:
	var hp: int;
	var max_hp: int;
	var dmg: int;
	var hit_chance: int;
	var crit_chance: int;
	var number_of_attacks: int;
	func _init(source: Unit, target: Unit):
		hp = source.hp;
		max_hp = source.max_hp;
		dmg = source.calculate_damage(target);
		hit_chance = source.calculate_hit_chance(target);
		crit_chance = source.calculate_crit_chance(target);
		number_of_attacks = source.calculate_number_of_attacks(target);
	

func _ready() -> void:
	destination = out_position;
	
	drop_button.focus_entered.connect(show_item_info);
	drop_button.focus_exited.connect(hide_item_info);
	drop_button.mouse_entered.connect(show_item_info);
	drop_button.mouse_exited.connect(hide_item_info);

func show_item_info() -> void:
	item_info.visible = true;
	var offset = -1.0 if drop_area.position.y < get_viewport().size.y/2.0 else 1.0;
	if (info_alignment == 0):
		item_info.position = floor(position+drop_area.position+drop_button.position+Vector2(drop_button.size.x+item_info_pad_value, offset*item_info.get_size().y/2.0));
	else:
		item_info.position = ceil(position+drop_area.position-Vector2(item_info_pad_value, 0.0)-Vector2(item_info.get_size().x, offset*item_info.get_size().y/2.0));
func hide_item_info() -> void:
	item_info.visible = false;
	
func set_engagement_forecast(player: PlayerUnit, opponent: EnemyUnit):
	left_component.set_info(EngagementInfo.new(player, opponent));
	right_component.set_info(EngagementInfo.new(opponent, player));
