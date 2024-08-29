extends Sprite2D;

class_name ToggleableSemitransparentSprite;

@export_range(0.0, 1.0) var untoggled_transparency: float;
@export_range(0.0, 1.0) var toggled_transparency: float;
@export_range(0.01, 1.0) var lerp_factor
var toggled = false;
var transparency_target = 0.0;

func _ready():
	transparency_target = untoggled_transparency;

func toggle():
	toggled = !toggled;
	if (toggled):
		transparency_target = toggled_transparency;
	else:
		transparency_target = untoggled_transparency;

func _process(_delta: float):
	modulate.a +=(transparency_target-modulate.a)*lerp_factor;
