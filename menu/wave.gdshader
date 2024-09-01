shader_type spatial;
render_mode unshaded;

uniform sampler2D wave_texture: filter_nearest;
uniform sampler2D noise_texture;
uniform float wave_strength = 1.0;
uniform float wave_scale = 0.02;
uniform float WaterOpacity = 1.0;
uniform vec2 uv_scale = vec2(1.0);

void vertex() {
    vec2 global_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
    float noise_value = texture(noise_texture, global_position * wave_scale).r;
    float wave = sin(global_position.x * 0.2 + global_position.y * 0.2 + TIME + noise_value * 10.0) * wave_strength;
    VERTEX.y += wave;
}

void fragment() {
    vec4 wave_color = texture(wave_texture, UV * uv_scale);
	
    ALBEDO = wave_color.rgb;
	ALPHA = WaterOpacity;
}