shader_type spatial;
render_mode blend_mix,depth_draw_alpha_prepass ,cull_disabled,diffuse_lambert,specular_schlick_ggx, skip_vertex_transform;
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

// Wind settings.
uniform float speed = 1.0;
uniform float strength = 0.1;
uniform float detail = 1.0;
uniform vec2 direction = vec2(1.0, 0.0);
uniform float heightOffset = 0.0;

// UV Uniforms must be after other uniforms because there is a bug with vec3. 
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

void vertex() {
	vec4 worldPos = WORLD_MATRIX * vec4(VERTEX, 1.0);

	float time = TIME * speed + worldPos.x + worldPos.z;
	float wind = (sin(time) + cos(time * detail)) * strength * max(0.0, VERTEX.y - heightOffset);
	vec2 dir = normalize(direction);
	worldPos.xz += vec2(wind * dir.x, wind * dir.y);
	VERTEX = (INV_CAMERA_MATRIX * worldPos).xyz;
	NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
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
	ALPHA = albedo.a * albedo_tex.a;
}
