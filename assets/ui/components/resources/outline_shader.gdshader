shader_type spatial;
render_mode unshaded, blend_mix; // unshaded para que ignore las sombras y brille

instance uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 0.0); // Color con transparencia

void fragment() {
	ALBEDO = color.rgb;
	ALPHA = color.a;
}