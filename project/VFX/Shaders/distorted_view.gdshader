shader_type canvas_item;

//Shader that displays the main viewport, but uses the displacement mask to
//distort the UVs and generate a shockwave or heattrail-like effect.

uniform float displacement_amount : hint_range(0, 18.0) = 5.0;
uniform sampler2D displacement_mask;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap, repeat_disable; //repeat_disable

void fragment() {
	float uv_displace_amount = displacement_amount * 1.0 / float(textureSize(screen_texture, 0).x);
	vec4 displacement = texture(displacement_mask, SCREEN_UV);
	vec2 displacement_uv = SCREEN_UV + displacement.xy * uv_displace_amount;
	COLOR = texture(screen_texture, displacement_uv);
}