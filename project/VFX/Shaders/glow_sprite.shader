shader_type canvas_item;

//Shader that draws a sprite that has a drawn-in glow effect on the original
// instead of generating a new glow. This makes it relatively high performance.
// The sprite is drawn twice, tinted seperately and blended together.
// The alpha_intensity_ variables control the falloff of the existing alpha's
// glow.

uniform float alpha_intensity_front : hint_range(0.0, 3.0) = 1.0;
uniform vec4 tint_front : hint_color = vec4(1.0,1.0,1.0,1.0);
uniform float alpha_intensity_back : hint_range(0.0, 3.0) = 1.0;
uniform vec4 tint_back : hint_color = vec4(1.0,1.0,1.0,1.0);
uniform float blend_amount : hint_range(0.0, 1.0) = 1.0;
uniform float fade_amount : hint_range(0.0, 1.0) = 1.0;

vec4 tint_rgba(vec4 tex, vec4 color) {
	float tint_amount = dot(tex.rgb, vec3(0.222, 0.707, 0.071));
	vec3 tint = color.rgb * tint_amount;
	tex.rgb = mix(tex.rgb, tint.rgb, color.a);
	return tex;
}

vec4 alpha_intensity(vec4 tex, float fade) {
	if(tex.a < 0.70) {
		tex.a = mix(0.0, tex.a, fade);
	}
	return tex;
}

vec4 blend(vec4 origin, vec4 overlay, float blend) {
	vec4 o = origin;
	o.a = overlay.a + origin.a * (1.0 - overlay.a);
	o.rgb = (overlay.rgb * overlay.a + origin.rgb * origin.a * (1.0 - overlay.a)) / (o.a + 0.0000001);
	o.a = clamp(o.a, 0.0, 1.0);
	o = mix(origin, o, blend);
	
	return o;
}

void fragment() {
	vec4 main_texture = texture(TEXTURE, UV);
	vec4 intensity_front_tex = alpha_intensity(main_texture, alpha_intensity_front);
	vec4 tint_front_tex = tint_rgba(intensity_front_tex, tint_front);
	
	vec4 intensity_back_tex = alpha_intensity(main_texture, alpha_intensity_back);
	vec4 tint_back_tex = tint_rgba(intensity_back_tex, tint_back);
	
	vec4 o = blend(tint_back_tex, tint_front_tex, blend_amount);
	o.rgb *= main_texture.rgb;
	o.a = o.a * fade_amount * main_texture.a;
	
	COLOR = o;
}