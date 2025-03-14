extends Node2D;
class_name EngagementForecastSubsection;

@export var health: Label
@export var stats_readout: VBoxContainer;
@export var damage: Label;
@export var attack_counter: Label;
@export var hit_chance: Label;
@export var crit_chance: Label;

var dimensions: Vector2;

func _ready() -> void:
	var w = (stats_readout.position.x+stats_readout.size.x)-position.x;
	var h = (stats_readout.position.y+stats_readout.size.y)-position.y;
	dimensions = Vector2(w, h);

func set_info(info: EngagementForecast.EngagementInfo) -> void:
	health.text = str(info.hp)+"/"+str(info.max_hp);
	damage.text = "DMG: "+str(info.dmg);
	attack_counter.text = "x"+str(info.number_of_attacks);
	hit_chance.text = "ACC: "+str(info.hit_chance);
	crit_chance.text = "CRIT: "+str(info.crit_chance);
