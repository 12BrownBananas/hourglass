shader_type canvas_item;

uniform float flash_intensity = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (COLOR.a > 0.0) {
		COLOR = mix(COLOR, vec4(1.0, 1.0, 1.0, COLOR.a), flash_intensity);
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
