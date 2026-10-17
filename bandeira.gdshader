shader_type spatial;
render_mode cull_disabled, diffuse_toon,depth_draw_opaque, blend_mix;
uniform sampler2D textura;
uniform float frequencia :hint_range(0.0,10.0)= 2.0;
//uniform float amplitude :hint_range(0.0, 10.0)= 0.2;
uniform float forca :hint_range(0.0, 10.0) = 7.0;
uniform float roughness :hint_range(0.0,1.0) = 1.0;
uniform float metallic :hint_range(0.0,1.0) = 1.0;
uniform float contraste :hint_range(0.0,10.0) = 2.0;

instance uniform float inclinacao :hint_range(-1.0, 1.0, 0.01) = 0.0;
instance uniform float centro_mastro = 1.0;
instance uniform float angulo :hint_range(0.0, 360.0, 0.01) = 90.0;
void vertex() {
	float amplitude = 0.2;
	float eixo_z = 0.0;
	float eixo_y = 0.0;
	//if(VERTEX.x < 0.5){
	if(amplitude > 0.0){
		amplitude=clamp(amplitude-(VERTEX.x*0.15),0.0,amplitude);
	}
	
	eixo_z = sin(TIME* forca+VERTEX.x*(frequencia+abs(inclinacao)*0.5))*amplitude;
	eixo_y = cos(TIME* forca+VERTEX.x*frequencia)*amplitude;
	//}
	
	VERTEX.y += eixo_y;
	VERTEX.z += eixo_z+sqrt(abs(-VERTEX.x+centro_mastro/2.0))*-inclinacao;
	float x = VERTEX.x-1.5;
	float y = VERTEX.y;
	
	VERTEX.x = x * cos(radians(angulo)) - y * sin(radians(angulo));
	VERTEX.y = x * sin(radians(angulo)) + y * cos(radians(angulo));
}

void fragment() {
	vec2 uv = UV;

	if(!FRONT_FACING){ 
		uv.x = uv.x*-1.0;
	}
	ALBEDO = (texture(textura,uv).rgb-0.5)*contraste+0.5;
	ROUGHNESS =roughness;
	METALLIC = metallic;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
