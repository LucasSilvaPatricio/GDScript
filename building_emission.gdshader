shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D textura_dia : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D textura_noite :source_color, filter_linear_mipmap, repeat_enable;
uniform vec3 albedo :source_color = vec3(1,1,1);
uniform float value :hint_range(0.0, 10.0, 0.01) = 0.0;

void vertex() {
	
	// Called for every vertex the material is visible on.
}

void fragment() {

	vec2 base_uv = UV2;
	
	vec4 albedo_tex = texture(textura_dia,base_uv);
	vec4 emission_tex = texture(textura_noite, base_uv);
	
	ALBEDO = albedo_tex.rgb;
	EMISSION=emission_tex.rgb *albedo * value;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
