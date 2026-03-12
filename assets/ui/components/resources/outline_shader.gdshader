shader_type spatial;
render_mode unshaded, blend_mix; // unshaded para que ignore las sombras y brille

instance uniform vec4 highlight_color : source_color = vec4(1.0, 0.0, 1.0, 0.5); // Color con transparencia

void fragment() {
	ALBEDO = highlight_color.rgb;
	ALPHA = highlight_color.a;
}