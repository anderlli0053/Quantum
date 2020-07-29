// 3d guncanje

shader_type spatial;
render_mode cull_disabled;

float hash(vec2 p) {
	return fract(sin(dot(p * 17.17, vec2(14.91, 67.31))) * 4791.9511);
}

float noise(vec2 x) {
	vec2 p = floor(x);
	vec2 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	vec2 a = vec2(1.0, 0.0);
	return mix(mix(hash(p + a.yy), hash(p + a.xy), f.x), mix(hash(p + a.yx), hash(p + a.xx), f.x), f.y);
}

float fbm(vec2 x) {
	float height = 0.0;
	float amplitude = 0.5;
	float frequency = 3.0;
	for (int i = 0; i < 6; i++) {
		height += noise(x * frequency) * amplitude;
		amplitude *= 0.5;
		frequency *= 2.0;
	}
	return height;
}

void vertex() {
	float n = noise(vec2(cos(TIME), sin(TIME)));
	float pivot_angle = cos(TIME) * n * 5.0;
	mat2 rotation_matrix = mat2(vec2(cos(pivot_angle), -sin(pivot_angle)), vec2(sin(pivot_angle), cos(pivot_angle)));
	VERTEX.yz = rotation_matrix * VERTEX.yz;
}

void fragment() {
	
}