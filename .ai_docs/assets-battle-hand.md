# `CardHandDisplay`
Este script extiende `Path2D` y funciona como un controlador para la visualización y gestión de la mano de cartas del jugador dentro del juego. Es responsable de instanciar dinámicamente las cartas, asignarles propiedades aleatorias (elemento y valor), distribuirlas a lo largo de la ruta definida por el `Path2D` y actualizar su estado visual (escala, posición y si están activas o desactivadas) en respuesta a cambios en las propiedades de la mano. La implementación permite una distribución visual fluida de las cartas y la capacidad de filtrar o deshabilitar cartas según el "elemento de roca" del jugador actual.

# Métodos

## Métodos de Godot

### `_ready()`
Este método se ejecuta una vez cuando el nodo `CardHandDisplay` y todos sus hijos están listos. Su función principal es inicializar el generador de números aleatorios (`rng`) y proceder con la creación inicial de las cartas que conformarán la mano del jugador.

Durante la inicialización:
1.  Se activa la semilla del generador de números aleatorios con `rng.randomize()`.
2.  Se itera `card_count` veces para crear una cantidad predefinida de cartas. En cada iteración:
    *   Se instancia un nuevo nodo `PathFollow2D`. Este nodo se utilizará para posicionar la carta a lo largo del `Path2D` padre.
    *   Se instancia una nueva carta a partir de la `card_scene` exportada.
    *   Se asignan propiedades aleatorias a la carta:
        *   El `element` se elige aleatoriamente de la enumeración `GameConstants.Elements`, asegurándose de que no sea `NONE`.
        *   El `value` se establece como un número entero aleatorio entre 1 y 10.
    *   Se llama al método `set_properties()` de la carta instanciada para aplicar estas propiedades.
    *   Se imprime un mensaje de depuración con el elemento y valor de la carta creada.
    *   La carta (`new_card`) se añade como hija del `PathFollow2D` (`new_card_pos`), y el `PathFollow2D` se añade como hijo del nodo `CardHandDisplay` actual.
3.  Finalmente, se invoca `refresh_cards()` para asegurar que todas las cartas recién creadas se posicionen y escalen correctamente desde el inicio.

```gdscript
func _ready() -> void:
	rng.randomize()

	# Crea las cartas
	for i in range(card_count):
		var new_card_pos := PathFollow2D.new()
		var new_card := card_scene.instantiate()

		# Establece los elementos y valores de las cartas
		var new_element: GameConstants.Elements

		# NONE significa 0 y el elemento empieza en null
		# Entonces este bucle evita que se eliga el elemento NONE
		@warning_ignore("unassigned_variable")
		while not new_element:
			new_element = GameConstants.Elements.values()[randi() % GameConstants.Elements.size()]

		new_card.set_properties({
			"element": new_element,
			"value": randi_range(1, 10),
			"hide_card": false,
		})

		print_debug("Carta creada: %s_%s" % [new_card.element, new_card.value])

		new_card_pos.add_child(new_card)
		add_child(new_card_pos)

	refresh_cards()
```

## Otros métodos

### `refresh_cards() -> void`
Este método es el encargado de actualizar la disposición visual de las cartas en la mano y su estado de interactividad. Se llama automáticamente cada vez que una de las propiedades exportadas (`card_scale`, `card_count`, `current_rock`) se modifica a través de sus `setter` definidos, o explícitamente desde `_ready()`.

El método realiza las siguientes acciones:
1.  Obtiene una lista de todos los hijos directos del nodo `Path2D` (que se espera que sean nodos `PathFollow2D` conteniendo las cartas).
2.  Si no hay cartas, el método retorna para evitar errores.
3.  Crea un nuevo `Tween` en modo paralelo. Esto permite que múltiples animaciones se ejecuten simultáneamente, proporcionando transiciones suaves para la posición de las cartas.
4.  Itera sobre cada `PathFollow2D` (que representa la posición de una carta):
    *   Calcula la `final_pos` (`progress_ratio`) para la carta, distribuyéndolas equitativamente a lo largo de la ruta definida por el `Path2D`. La fórmula `float(card_count - i - 1) / max(card_count - 1, 1)` asegura que las cartas se distribuyan desde el final al principio de la ruta, ocupando todo el espacio disponible.
    *   Usa el `tween` para animar la propiedad `progress_ratio` del `PathFollow2D` a su `final_pos` durante 0.2 segundos.
    *   Establece la `scale` de la carta al valor de `card_scale` definido, asegurando que todas las cartas tengan el mismo tamaño.
    *   Aplica la lógica de deshabilitación de cartas:
        *   Si `current_rock` no es `GameConstants.Elements.NONE`, la carta se deshabilitará (`card.disable_card = true`) si su elemento no coincide con el `current_rock`.
        *   Si `current_rock` es `GameConstants.Elements.NONE`, todas las cartas se activan (`card.disable_card = false`).

    > **Nota:** La lógica de deshabilitación asume que la `card_scene` instanciada tiene las propiedades `element` y `disable_card`, y que `disable_card` controla alguna representación visual o interactiva de la carta.

```gdscript
func refresh_cards() -> void:
	var cards_pos := get_children()
	if cards_pos.is_empty(): return

	var tween := create_tween().set_parallel()

	for i in cards_pos.size():
		var card_pos: PathFollow2D = cards_pos[i]
		var card: Control = card_pos.get_child(0)

		# Posición y tamaño
		var final_pos = float(card_count - i - 1) / max(card_count - 1, 1) if i < card_count else 0
		tween.tween_property(card_pos, "progress_ratio", final_pos, 0.2)
		card.scale = Vector2(card_scale, card_scale)

		# Desactiva las cartas que no son del elemento actual
		if current_rock != GameConstants.Elements.NONE:
			card.disable_card = card.element != current_rock
		else:
			card.disable_card = false
```