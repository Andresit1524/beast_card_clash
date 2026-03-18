shader_type spatial;
render_mode cull_front, unshaded;


instance uniform vec4 color : source_color = vec4(1.0, 0.0, 1.0, 1.0);
instance uniform float thickness : hint_range(0.0, 1.0, 0.01) = 0.05;


void vertex() {
    // Escala la posición del vértice desde el centro, ignorando las normales divididas
    VERTEX += normalize(VERTEX) * thickness;

    // Alternativa (usa una a la vez)
    // VERTEX *= 1.0 + thickness;
}


void fragment() {
	// Pinta la malla expandida
	ALBEDO = color.rgb;
}
