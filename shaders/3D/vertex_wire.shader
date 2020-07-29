shader_type spatial;
render_mode unshaded;

void vertex(){
	POINT_SIZE = 10.0;
	if (!OUTPUT_IS_SRGB) {
		COLOR.rgb = mix( pow((COLOR.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)), COLOR.rgb* (1.0 / 12.92), lessThan(COLOR.rgb,vec3(0.04045)) );
	}
}

void fragment(){
	vec4 screen_color = texture(SCREEN_TEXTURE,SCREEN_UV);
	ALBEDO = mix(screen_color.rgb,COLOR.rgb,clamp(dot(NORMAL,vec3(0.0,0.0,1.0)),0.8,1.0));
}