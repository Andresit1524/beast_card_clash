shader_type spatial;
render_mode unshaded, blend_mix; // unshaded para que ignore las sombras y brille

instance uniform vec4 color : source_color = vec4(0.0, 1.0, 1.0, 0.2); // Color con transparencia

const float speed_scale = 4.0; // Velocidad de oscilación
const float min_alpha = 0.0; // Transparencia mínima

void fragment() {
	ALBEDO = color.rgb;

	// Oscila la transparencia del resaltado
	float alpha_scale = ((color.a - min_alpha) * sin(TIME * speed_scale) + (color.a + min_alpha)) * 0.5;
	ALPHA = color.a * alpha_scale;
}