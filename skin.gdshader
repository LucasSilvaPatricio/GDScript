shader_type canvas_item;

uniform sampler2D skin :source_color;
instance uniform vec4 modulate :source_color = vec4(1.0,1.0,1.0,1.0);
uniform float tolerance_white = 0.99;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 cor = texture(skin,UV);
	vec4 final_color = cor;
	
	for(int i = 0; i < 3; i++){
		final_color[i] *= final_color[i] > tolerance_white?1.0:modulate[i];
	}
	COLOR = vec4(1.5*pow(final_color.rgb,vec3(0.9)),final_color.a);
}
