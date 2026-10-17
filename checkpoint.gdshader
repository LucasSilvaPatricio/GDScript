shader_type spatial;
render_mode cull_back;

uniform sampler2D textura :filter_nearest;
uniform float velocidade_rotacao = 50.0;
instance uniform float velocidade = 5.0;
instance uniform float amplitude = 0.2;
instance uniform vec3 cor :source_color = vec3(1.0,1.0,1.0);
instance uniform vec3 cor_secundaria :source_color = vec3(1.0,1.0,1.0);

void vertex() {
	
	
	float x = VERTEX.x;
	float z = VERTEX.z;
	
	float rot = 0.0;
	rot += TIME*velocidade_rotacao;
	float angulo = rot;
	VERTEX.x = x * cos(radians(angulo)) - z*sin(radians(angulo));
	VERTEX.z = x * sin(radians(angulo)) + z*cos(radians(angulo));
	
}

void fragment() {
	vec4 t = texture(textura, UV);
	float alternar = clamp(sin(TIME),0.0,1.0);
	ALBEDO = t.rgb*cor;
	ALPHA = t.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
