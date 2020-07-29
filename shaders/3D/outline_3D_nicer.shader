shader_type spatial;
render_mode skip_vertex_transform, unshaded, blend_mul;
uniform float edge_width;
uniform float edge_multiplier;


void vertex()
{
	PROJECTION_MATRIX = mat4(1.0);
}



void fragment()
{
	float edge = edge_width/1000f;
	float edge_power = edge_multiplier/1000f;
	float edge_final;
	vec4 screen = -8f * texture(DEPTH_TEXTURE,SCREEN_UV);
	screen += texture(DEPTH_TEXTURE,SCREEN_UV + vec2(0f, edge));
	screen += texture(DEPTH_TEXTURE,SCREEN_UV + vec2(0f, -edge));
	screen += texture(DEPTH_TEXTURE,SCREEN_UV + vec2(edge, 0f));
	screen += texture(DEPTH_TEXTURE,SCREEN_UV + vec2(-edge, 0f));
	screen += texture(DEPTH_TEXTURE,SCREEN_UV + vec2(edge, edge));
	screen += texture(DEPTH_TEXTURE,SCREEN_UV + vec2(edge, edge));
	screen += texture(DEPTH_TEXTURE,SCREEN_UV + vec2(-edge, edge));
	screen += texture(DEPTH_TEXTURE,SCREEN_UV + vec2(edge, -edge));
	screen = sqrt(screen * screen);
	
	
	if (screen.r < edge_power)
	{
		edge_final = 1f;
	}
	
	else
	{
		edge_final = 0f;
	}
	
	ALBEDO = vec3(edge_final);
	
}