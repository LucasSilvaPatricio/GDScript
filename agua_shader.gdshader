shader_type spatial;

render_mode depth_draw_always,cull_disabled;

uniform vec3 cor :source_color = vec3(1.0,1.0,1.0);
uniform float alpha :hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float contraste = 0.0;
uniform float roughness :hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float mettalic :hint_range(0.0, 1.0, 0.01) = 0.0;
uniform sampler2D textura;
uniform sampler2D heightmap;
uniform sampler2D normalmap;
uniform float normalmap_height = 1.0;
uniform float lenghtmap_scale = 0.0;
uniform float velocity = 0.001;
uniform float velocity_uv = 1.0;
uniform float scale_wave = 1.0;
uniform float frequency = 1.0;
uniform float scale_uv = 1.0;


void vertex() {
	float x = VERTEX.x;
	float z = VERTEX.z;
	VERTEX.y += sin(TIME*velocity+VERTEX.x*frequency)*scale_wave;
	VERTEX.y += cos(TIME*velocity+VERTEX.z*frequency)*scale_wave;
	float lenght = texture(heightmap,UV*scale_uv).r;
	VERTEX += NORMAL*lenght*lenghtmap_scale;
}

void fragment() {
	vec2 uv = UV;
	uv.x -= sin(TIME*velocity_uv)*0.01;
	uv.y -= cos(TIME*velocity_uv)*0.01;
	ALBEDO = (texture(textura,uv*scale_uv).rgb*cor-0.5)*contraste+0.5;
	ALPHA = alpha;
	ROUGHNESS = roughness;
	METALLIC = mettalic;
	NORMAL_MAP = texture(normalmap,UV*scale_uv).rgb*vec3(1.0,1.0,1.0)*normalmap_height;
}
