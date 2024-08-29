extends Node2D;
class_name DialogBox;

@export var prompt: Label;
@export var yes_button: Button;
@export var no_button: Button;

func _ready():
	yes_button.pressed.connect(on_confirm);
	no_button.pressed.connect(on_reject);

func on_confirm():
	print("Confirmation!");
	visible = false;

func on_reject():
	print("Rejection!");
	visible = false;

func set_prompt(prompt_string: String):
	prompt.text = prompt_string;
