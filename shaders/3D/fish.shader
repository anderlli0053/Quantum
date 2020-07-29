shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

// fish params
uniform float timer;

uniform float twist_factor;
uniform float twist_factor_frequency;
uniform float s_factor;
uniform float s_factor_frequency;

uniform float frequency;
uniform float yaw_factor;
uniform vec3 translate;

uniform float head_z;
uniform vec4 head_color;
uniform float tail_z;
uniform vec4 tail_color;

// standard params
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform sampler2D texture_metallic : hint_white;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_white;
uniform vec4 roughness_texture_channel;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

void vertex() {
	
	float tmult = sin( timer * frequency );
	
	vec3 new_pos = VERTEX;
	vec3 tmp = VERTEX;
	// mix
	float dist_ht = tail_z - head_z;
	float ranged_z = ( min( max( VERTEX.z, head_z ), tail_z ) - head_z ) / dist_ht;
	vec4 ctrl_color = tail_color * ranged_z + head_color * (1.0-ranged_z);
	
	// twist
	float twist_a = ctrl_color.r * sin( VERTEX.z + timer * twist_factor_frequency ) * twist_factor;
	float twist_cos = cos( twist_a );
	float twist_sin = sin( twist_a );
	tmp.x = new_pos.x * twist_cos - new_pos.y * twist_sin;
	tmp.y = new_pos.x * twist_sin + new_pos.y * twist_cos;
	new_pos = tmp;
	
	// S factor
	float s_a = ctrl_color.g * sin( VERTEX.z - timer * s_factor_frequency ) * s_factor;
	new_pos.x += s_a;
	
	// yaw
	float yaw_a = ctrl_color.b * tmult * yaw_factor;
	float yaw_cos = cos( yaw_a );
	float yaw_sin = sin( yaw_a );
	tmp.x = new_pos.x * yaw_cos - new_pos.z * yaw_sin;
	tmp.z = new_pos.x * yaw_sin + new_pos.z * yaw_cos;
	new_pos = tmp;
	
	// translation
	new_pos += ctrl_color.a * translate * tmult;

	VERTEX = new_pos;
	
	// UV
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
}
