shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D dither;
uniform float dither_scale = 1.0;
uniform float color_alpha = 0.26;

void vertex(){
	POINT_SIZE = 4.0;
	if (!OUTPUT_IS_SRGB) {
		COLOR.rgb = mix( pow((COLOR.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)), COLOR.rgb* (1.0 / 12.92), lessThan(COLOR.rgb,vec3(0.04045)) );
	}
}

void fragment(){
	
	ivec2 dither_size = textureSize(dither,0);
	vec2 pos = mod(vec2(FRAGCOORD.x+COLOR.r+COLOR.b,FRAGCOORD.y+COLOR.g+COLOR.b)/dither_scale/vec2(float(dither_size.x),float(dither_size.y)),vec2(1.0,1.0));
	float threshold = texture(dither,pos).r;
	
	ALBEDO = COLOR.rgb;
	//ALPHA=0.9;
	
	if(color_alpha-threshold < 0.0){
		discard;
	}
}