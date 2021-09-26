shader_type canvas_item;

void fragment() {
	float color_multiplier = pow(TIME * 0.5, 2.);
	color_multiplier = min(1., color_multiplier);
	COLOR = texture(TEXTURE, UV) * color_multiplier;
}