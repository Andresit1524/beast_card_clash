# `CardsList`
Este script define la clase `CardsList`, una `Resource` que funciona como un contenedor centralizado para las texturas visuales de las cartas del juego. Su propósito principal es almacenar de forma organizada las `Texture2D` de cada carta, clasificadas por su elemento, y proveer un método eficiente para acceder a una carta específica utilizando su elemento y valor. Al ser una `Resource`, puede ser creada, configurada en el editor de Godot (donde se asignan las texturas a sus respectivas arrays), y luego cargada y utilizada en cualquier parte del proyecto, facilitando la gestión de assets de cartas y promoviendo la reutilización.

# Métodos

## Otros métodos

### `get_card(element: int, value: int) -> Texture2D`
Este método es la interfaz principal para recuperar una textura de carta de la colección. Recibe dos parámetros enteros: `element` y `value`.

- **`element`**: Representa el tipo elemental de la carta que se desea obtener. Se espera que este parámetro sea uno de los valores definidos en la enumeración `GameConstants.Elements` (por ejemplo, `GameConstants.Elements.AIR`, `GameConstants.Elements.FIRE`, etc.).
- **`value`**: Representa el valor numérico de la carta dentro de su elemento. Se asume que las cartas tienen un valor base de 1, por lo que este valor se ajusta internamente (`value - 1`) para coincidir con los índices base cero de los arrays de Godot.

El método utiliza una estructura `match` para determinar qué array de texturas debe consultar, basándose en el parámetro `element`.

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

- Si el `element` es `GameConstants.Elements.NONE`, o si el `element` no coincide con ninguna de las categorías elementales predefinidas, el método devuelve la textura `placeholder`.
- En caso de que se pase un valor `element` que no esté contemplado, el sistema emitirá un error utilizando `push_error("Carta no identificada")` en la consola de Godot, lo que ayuda a depurar el uso incorrecto del método.
- Para los elementos válidos, accede al array correspondiente (ej. `air_cards`) y utiliza `value - 1` como índice para obtener la textura específica, asumiendo una numeración de cartas que comienza desde 1.

Este diseño permite una gestión robusta y flexible de las imágenes de las cartas, desacoplando la lógica de obtención de la carta de la representación visual directa en otros componentes del juego.