shader_type spatial;

uniform float amplitude = 0.01;
void vertex() {
	float x = 0.0;
	//VERTEX.y += (sqrt(VERTEX.x)-1.0-sqrt(1.0-pow(VERTEX.x,2.0)))/2.0;
	//VERTEX.y += (-sqrt(1.0-pow(VERTEX.x,2.0)+sqrt(-VERTEX.x)-1.0))/2.0;
}

void fragment() {
	ALBEDO = vec3(1.0,0.0,0.0);
		float x = 0.0;
	//VERTEX.y += (sqrt(VERTEX.x)-1.0-sqrt(1.0-pow(VERTEX.x,2.0)))/2.0;
	//VERTEX.y += (-sqrt(1.0-pow(VERTEX.x,2.0)+sqrt(-VERTEX.x)-1.0))/2.0;
	ROUGHNESS = 0.1;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
