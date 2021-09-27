shader_type canvas_item;
render_mode blend_add;

uniform float delay;
uniform float direction;

void fragment() {
	float pieces = 30.;
	float speed_scale = 3.;
	float dot = step(sin(TIME * speed_scale + delay) / 2. + 0.5, floor(UV.x * pieces) / pieces);
	dot -= step(sin(TIME * speed_scale + 0.1 + delay) / 2. + 0.5, floor(UV.x * pieces) / pieces);
	dot = abs(dot);
	COLOR = vec4(vec3(dot), texture(TEXTURE, UV).a);
//	COLOR = vec4(UV.x);
}