extends ColorRect
@export var text: Label;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (size != text.size):
		size = text.size;
