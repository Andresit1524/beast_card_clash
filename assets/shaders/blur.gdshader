shader_type canvas_item;

// Permite acceder a lo que se renderizó antes que este objeto
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float lod: hint_range(0.0, 5.0) = 2.0; // Intensidad del desenfoque
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 0.5); // Color y transparencia

void fragment() {
    // Obtenemos el color del fondo con un nivel de detalle (LOD) para el blur
    vec4 color = textureLod(screen_texture, SCREEN_UV, lod);

    // Mezclamos el fondo borroso con el color de tinte (tint)
    // El valor tint.a (alpha) controla qué tanto predomina el color sobre el blur
    COLOR = mix(color, vec4(tint.rgb, 1.0), tint.a);
}
