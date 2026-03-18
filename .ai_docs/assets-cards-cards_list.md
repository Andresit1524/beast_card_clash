# `CardsList`
Este script define la clase `CardsList`, que extiende `Resource`. Su propósito principal es servir como un repositorio centralizado y configurable para las texturas (`Texture2D`) de todas las cartas coleccionables del juego **Beast Card Clash**. Permite a otros componentes del juego acceder a la representación visual de una carta específica mediante su elemento y su valor numérico.

Al ser una `Resource`, las instancias de `CardsList` pueden crearse y guardarse como archivos `.tres` directamente en el editor de Godot. Esto facilita a los diseñadores la asignación y organización de los `Texture2D` de las cartas para cada tipo elemental (Aire, Tierra, Energía, Fuego y Agua), así como una textura de "placeholder" para casos predeterminados o de error. Esta estructura promueve una arquitectura de juego data-driven, desacoplando los activos visuales de la lógica de juego y mejorando la gestión y escalabilidad de las cartas.

La clase actúa como una tabla de consulta eficiente, permitiendo que elementos como nodos que muestran cartas o gestores de mazos obtengan la textura correcta para la carta en cuestión, garantizando coherencia visual y facilidad de mantenimiento del arte del juego.

## Métodos

### `get_card(element: int, value: int) -> Texture2D`
Este es el método principal y público de la clase `CardsList`. Su función es recuperar la textura (`Texture2D`) correspondiente a una carta específica, basándose en su tipo elemental y su valor numérico.

- **Parámetros:**
    - `element: int`: Representa el tipo elemental de la carta. Se espera que este valor corresponda con las constantes definidas en una enumeración o clase de constantes globales del proyecto, presumiblemente `GameConstants.Elements` (ej. `GameConstants.Elements.AIR`).
    - `value: int`: Un valor entero que indica la "fuerza" o el orden de la carta dentro de su elemento. Para mayor claridad en el diseño del juego, se asume que este valor es 1-indexado (es decir, el primer valor es 1, el segundo es 2, y así sucesivamente).

- **Funcionamiento:**
    El método utiliza una declaración `match` para evaluar el `element` proporcionado:
    - Si el `element` es `GameConstants.Elements.NONE`, o si el valor no coincide con ninguno de los elementos reconocidos, el método devuelve la textura asignada a la variable `@export var placeholder`.
    - Para cada elemento reconocido (`AIR`, `EARTH`, `ENERGY`, `FIRE`, `WATER`), el método accede al array de texturas correspondiente (ej. `air_cards`) y devuelve la `Texture2D` en la posición `value - 1`. La operación `value - 1` es crucial porque los arrays en GDScript son 0-indexados, lo que convierte el valor de carta 1-indexado en el índice de array correcto.

- **Manejo de errores:**
    En caso de que el valor del parámetro `element` no corresponda a ninguno de los elementos definidos y manejados por el `match` (lo que indicaría un valor inesperado o no soportado), el método emitirá un error en la consola de Godot a través de `push_error("Carta no identificada")`. Después de registrar el error, devolverá la textura `placeholder` como una medida de seguridad para evitar que el programa falle o intente acceder a un recurso inexistente.

```gdscript
func get_card(element: int, value: int) -> Texture2D:
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

	push_error("Carta no identificada")
	return placeholder
```