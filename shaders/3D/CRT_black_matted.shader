shader_type spatial;

render_mode blend_mix,depth_draw_opaque,cull_back, specular_schlick_ggx, diffuse_burley;

uniform vec4 albedo : hint_color;
uniform vec4 color_adjustments : hint_color;
uniform vec3 saturation_brightness_contrast = vec3(1.0,0.0,1.0);
uniform float back_light : hint_range(0.0,4.0);
uniform float light_leak : hint_range(0.0,1.0);
uniform sampler2D texture_color : hint_albedo;
uniform sampler2D texture_pixels : hint_white;
uniform sampler2D texture_stagger : hint_black;
uniform sampler2D texture_warp : hint_black;


uniform vec2 uv_scale = vec2(1.0,1.0);
uniform vec2 uv_offset = vec2(0.0,0.0);
uniform vec2 stagger_scale = vec2(1.0,1.0);
uniform vec2 stagger_offset = vec2(0.0,0.0);
uniform vec2 warp_scale = vec2(1.0,1.0);
uniform vec2 warp_offset = vec2(0.0,0.0);
uniform float warp_amount = 1.0;
uniform vec2 pixels = vec2(128.0,128.0);

uniform float blur = 0.0;
uniform float pixel_fade_depth = 2.0;
uniform float scan_fade_depth = 2.0;
uniform float scan_intensity = 0.5;
uniform float scan_line_spacing = 3.0;
uniform float scan_line_width = 1.0;
uniform float scan_speed = 0.01;
uniform vec2 scan_direction = vec2(0.0,1.0);
uniform bool solid_scan_line = false;

uniform float vignette_falloff = 0.0;
uniform float vignette_amount = 1.0;

uniform float noise_amount = 0.0;
uniform vec2 noise_scale = vec2(1.0,1.0);
uniform float noise_speed = 0.0;

uniform float roughness = 0.0;
uniform float specular = 0.0;

void vertex() {
	UV=UV*uv_scale+uv_offset;
}

void fragment(){
	
	float pixel_fade = clamp(smoothstep(VERTEX.z+pixel_fade_depth,VERTEX.z,0.0),0.0,1.0);
	float scan_fade = clamp(smoothstep(VERTEX.z+scan_fade_depth,VERTEX.z,0.0),0.0,1.0);
	
	vec2 base_uv = floor(UV*(pixels/uv_scale))/(pixels/uv_scale);
	
	vec2 pixel_uv = UV*(pixels/uv_scale);
	vec2 stagger_uv = pixel_uv*stagger_scale+stagger_offset;
	vec4 stagger_tex = textureLod(texture_stagger,stagger_uv,0.0);
	vec4 pixel_tex = textureLod(texture_pixels,pixel_uv+stagger_tex.xy,(1.0-pixel_fade)*2.0);
	
	vec2 color_uv = floor(UV*(pixels/uv_scale)+stagger_tex.xy)/(pixels/uv_scale);
	vec4 warp_tex = textureLod(texture_warp,color_uv*warp_scale+warp_offset,0.0);
	color_uv += warp_tex.xy*warp_amount;
	vec4 color_tex = textureLod(texture_color,color_uv,blur);
	
	
	float line = clamp(1.0-(mod((TIME*scan_speed-UV.y/uv_scale.y*scan_direction.y-UV.x/uv_scale.x*scan_direction.x)*length(pixels),scan_line_spacing))/length(pixels*scan_line_width),0.0,1.0);
	if(solid_scan_line == true){
		line = ceil(line);
	}
	float noise = fract(sin(dot(floor(pixel_uv+stagger_tex.xy)*noise_scale ,vec2(12.9898,78.233))) * (43758.5453+TIME*noise_speed)) * noise_amount;
	
	SPECULAR = specular;
	ROUGHNESS = roughness;
	
	ALBEDO = albedo.rgb * albedo.a;
	
	vec3 final_color = color_tex.rgb * color_adjustments.rgb * color_tex.a;
	
	//Saturation
    vec3 W = vec3(0.2125, 0.7154, 0.0721);
    vec3 intensity = vec3(dot(final_color, W));
    final_color = mix(intensity, final_color, saturation_brightness_contrast.x);
	//contrast and brightness
	final_color = (clamp(final_color * saturation_brightness_contrast.z + saturation_brightness_contrast.y,0.0,1.0)*color_adjustments.a);
	
	EMISSION = mix(vec3(0.0),final_color,back_light) * (1.0-pixel_fade);
	EMISSION += mix(vec3(0.0),final_color * pixel_tex.rgb,back_light-light_leak) * pixel_fade;
	
	float dist = distance((base_uv-uv_offset)/uv_scale, vec2(0.5, 0.5));
	EMISSION *= smoothstep(0.8, vignette_falloff * 0.799, dist * (vignette_amount + vignette_falloff));
	
	EMISSION = clamp(EMISSION,0.0,1.0);
	
	//Extra light
	
	vec3 leak_color = mix(vec3(0.0),vec3(back_light),light_leak * (1.0+pixel_fade));
	EMISSION += leak_color * (1.0-pixel_fade);
	EMISSION += leak_color * pixel_tex.rgb * pixel_fade;
	EMISSION *= 1.0+(line*(scan_fade*scan_intensity) + scan_intensity*(1.0-scan_fade));
	
	EMISSION *= clamp(1.0-noise,0.0,1.0);
}