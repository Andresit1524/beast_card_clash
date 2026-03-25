shader_type spatial;
render_mode cull_front, unshaded;

instance uniform vec4 color : source_color = vec4(0.0, 1.0, 1.0, 0.2); // Color de borde
instance uniform float thickness : hint_range(0.0, 1.0, 0.01) = 0.1; // Grosor

const float speed_scale = 4.0; // Velocidad de oscilación
const float min_thickness = 0.05; // Grosor mínimo

void vertex() {
	if (thickness > 0.0) {
		// Oscila el grosor
		float thickness_scale = ((thickness - min_thickness) * sin(TIME * speed_scale) + (thickness + min_thickness)) * 0.5;

		// Escala la posición del vértice desde el centro, ignorando las normales divididas
		VERTEX += normalize(VERTEX) * thickness_scale;

        // Alternativa (usa una a la vez)
        // VERTEX *= 1.0 + thickness_scale;
	}
}

void fragment() {
	if (thickness <= 0.0) { discard; }

	// Pinta la malla expandida
	ALBEDO = color.rgb;
}
