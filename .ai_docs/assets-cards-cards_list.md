# `CardsList`
`CardsList` es una clase auxiliar que extiende `Resource`, lo que le permite ser un activo persistente en el proyecto Godot, fácilmente editable desde el editor. Su función principal es actuar como un contenedor centralizado para las texturas (`Texture2D`) de todas las cartas del juego, organizadas por su elemento. Esto facilita la gestión y el acceso a los gráficos de las cartas a lo largo del proyecto, permitiendo que otras partes del juego consulten y muestren la textura correcta para cualquier carta dada su elementalidad y valor numérico. La estructura de este `Resource` está diseñada para ser configurable por diseñadores de juego a través del editor, sin necesidad de modificar el código.

# Métodos

## Otros métodos

### `get_card(element: int, value: int) -> Texture2D`
Este método es el corazón de la clase `CardsList`, diseñado para recuperar la `Texture2D` correspondiente a una carta específica.

**Parámetros:**
- `element`: Un entero que representa el tipo elemental de la carta. Se espera que estos valores enteros correspondan a las constantes definidas en `GameConstants.Elements` (e.g., `GameConstants.Elements.AIR`, `GameConstants.Elements.FIRE`).
- `value`: Un entero que representa el valor numérico de la carta.

**Funcionamiento:**
El método utiliza una declaración `match` para evaluar el parámetro `element` y seleccionar el array de texturas correspondiente:
```gdscript
match element:
	GameConstants.Elements.NONE:
		return placeholder
	GameConstants.Elements.AIR:
		return air_cards[value - 1]
	GameConstants.Elements.EARTH:
		return earth_cards[value - 1]
	GameConstants.Elements.ENERGY:
		return energy_cards[value - 1]
	GameConstants.Elements.FIRE:
		return fire_cards[value - 1]
	GameConstants.Elements.WATER:
		return water_cards[value - 1]
```

- Si el `element` es `GameConstants.Elements.NONE`, devuelve la textura `placeholder`, que actúa como un sustituto o una carta vacía.
- Para cada elemento reconocido (`AIR`, `EARTH`, `ENERGY`, `FIRE`, `WATER`), el método accede al array de texturas correspondiente (`air_cards`, `earth_cards`, etc.).
- La `Texture2D` se recupera utilizando `value - 1` como índice. Esto asume que los valores de las cartas empiezan en `1` y que los arrays en GDScript son de base cero.
- Si el `element` proporcionado no coincide con ningún tipo elemental conocido, el método registrará un error utilizando `push_error("Carta no identificada")` y devolverá la textura `placeholder` como medida de seguridad para evitar un fallo.

**Propósito en el juego:**
Este método será utilizado por componentes que necesiten visualizar cartas, como la interfaz de usuario de la mano del jugador, los elementos visuales de la mesa de duelo, o los contenedores de cartas en el mundo. Al invocar `get_card` con el elemento y valor de una carta, se obtiene directamente el recurso `Texture2D` necesario para su renderizado.