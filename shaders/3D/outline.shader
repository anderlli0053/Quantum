shader_type spatial;
render_mode unshaded;

uniform float x_ray_transparency = 0.1;


void vertex(){
	POINT_SIZE = 8.0;
	if (!OUTPUT_IS_SRGB) {
		COLOR.rgb = mix( pow((COLOR.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)), COLOR.rgb* (1.0 / 12.92), lessThan(COLOR.rgb,vec3(0.04045)) );
	}
}

void fragment(){
//	mat4 dither = mat4(
//		vec4(1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0),
//		vec4(13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0),
//		vec4(4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0),
//		vec4(16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0)
//	);
//	vec2 pos = vec2(floor(mod(FRAGCOORD.x,4.0)),floor(mod(FRAGCOORD.y,4.0)));
//	vec4 x;
//	if(pos.x == 0.0){x = dither[0];}
//	else if(pos.x == 1.0){x = dither[1];}
//	else if(pos.x == 2.0){x = dither[2];}
//	else if(pos.x == 3.0){x = dither[3];}
//
//	float threshold;
//	if(pos.y == 0.0){threshold = x[0];}
//	if(pos.y == 1.0){threshold = x[1];}
//	if(pos.y == 2.0){threshold = x[2];}
//	if(pos.y == 3.0){threshold = x[3];}
	
	float fade_distance = -VERTEX.z;
	float fd = clamp(smoothstep(0.0,1.0,fade_distance),0.0,1.0);
	
	float fade = dot(NORMAL,vec3(0.0,0.0,1.0));
	float fade_curve = clamp(-pow(fade,2.0)+1.0,0.0,1.0);
	float fp = (clamp(fade_curve,x_ray_transparency,1.0) + clamp(fade*0.5+0.5,0.0,1.0))*0.5;
	float f = clamp(fp,x_ray_transparency,1.0);
	
	vec4 screen_color = texture(SCREEN_TEXTURE,SCREEN_UV);
	
	ALBEDO = mix(screen_color.rgb * COLOR.rgb,(vec3(1.0) - screen_color.rgb)*COLOR.rgb,fade);
//	if(f-threshold < -x_ray_transparency){
//		discard;
//	}
	
}