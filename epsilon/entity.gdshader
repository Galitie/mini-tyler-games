shader_type canvas_item;

uniform vec4 origin: source_color;
uniform vec4 new: source_color;
uniform bool is_hit;

void fragment() {
	vec4 current_pixel = texture(TEXTURE, UV);
	
	if (round(current_pixel) == round(origin))
		COLOR = new;
		
	if (is_hit == true)
		if (round(current_pixel).a == 1.0)
			COLOR = vec4(1.0, 0.0, 0.0, 1.0);
}
