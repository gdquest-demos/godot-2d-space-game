shader_type canvas_item;


uniform float displacement_amount : hint_range(0, 18.0) = 5.0;
uniform sampler2D displacement_mask;


void fragment() {
	float uv_displace_amount = displacement_amount * 1.0 / float(textureSize(SCREEN_TEXTURE, 0).x);
	vec4 displacement = texture(displacement_mask, UV);
	vec2 displacement_uv = UV + displacement.xy * uv_displace_amount;
	COLOR = texture(SCREEN_TEXTURE, displacement_uv);
}