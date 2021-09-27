shader_type canvas_item;
//render_mode blend_add;

varying vec2 pos;

void vertex() {
	pos = (WORLD_MATRIX * vec4(VERTEX, 0., 1.)).xy;
}

void fragment() {
	float pieces = 30.;
	float speed_scale = 3.;
	float dot = step(sin(TIME * speed_scale + pos.x / 800.) / 2. + 0.5, floor(UV.x * pieces) / pieces);
	dot -= step(sin(TIME * speed_scale + 0.1 + pos.x / 800.) / 2. + 0.5, floor(UV.x * pieces) / pieces);
	dot = abs(dot);
	vec4 tex = texture(TEXTURE, UV);
	tex.rgb += dot;
//	color += dot;
	COLOR = vec4(tex.rgb, tex.a);
}