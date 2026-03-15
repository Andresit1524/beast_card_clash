# `Card`
Este script define el comportamiento y la apariencia de una carta individual en el juego **Beast Card Clash**. Extiende de `TextureButton`, lo que le permite ser un elemento interactivo de la interfaz de usuario con capacidades visuales y de entrada. Su función principal es representar visualmente una carta del juego, incluyendo su elemento, valor, estado (oculta, deshabilitada) y gestionar sus interacciones visuales, como el efecto de `hover` y la animación de rotación al ocultarse/mostrarse.

La carta fusiona conceptos de estrategia con la temática de animales colombianos y facultades de la UNAL, según lo descrito en el `README.md`. Este componente es fundamental para la interacción del jugador con el mazo y el campo de juego.

# Métodos

## Métodos de Godot

### `_ready()`
Este método se ejecuta una vez cuando el nodo `Card` y sus hijos han entrado en el árbol de escenas. Su propósito es inicializar el estado de la carta:

1.  **Almacenamiento del estado inicial:** Guarda la posición (`position`), tamaño (`size`) y escala (`scale`) iniciales de la carta en las variables privadas `_start_pos`, `_start_size` y `_start_scale`, respectivamente. Esto es crucial para poder revertir los efectos de `hover` a su estado original.
2.  **Centrado del pivote:** Establece el punto de pivote (`pivot_offset`) de la carta en su centro (`size / 2`). Esto asegura que las transformaciones (como el escalado o la rotación) se realicen desde el centro de la carta, lo que es esencial para la animación de rotación al ocultar/mostrar la carta.
3.  **Actualización visual inicial:** Llama a `update_sprite()` para asegurar que la carta muestre la textura correcta y el estado visual apropiado (color, imagen) al inicio, basándose en las propiedades de `element`, `value`, `hide_card` y `disable_card` que puedan haber sido establecidas en el editor o en el código.

```gdscript
func _ready() -> void:
	_start_pos = position
	_start_size = size
	_start_scale = scale

	# Centra el pivote
	pivot_offset = size / 2

	update_sprite()
```

## Otros métodos

### `set_properties(values: Dictionary)`
Este método es una utilidad para asignar múltiples propiedades de la carta simultáneamente a partir de un diccionario. Esto puede ser útil para inicializar o actualizar la carta de forma programática con un conjunto de atributos.

1.  **Iteración sobre propiedades:** Recorre cada par `propiedad: valor` en el diccionario `values`.
2.  **Validación de propiedad:** Verifica si la `propiedad` existe como un miembro del script `Card` (`if not property in self:`). Si una propiedad no es encontrada, emite un error para depuración.
3.  **Asignación de valor:** Utiliza `set(property, new_value)` para asignar el `new_value` a la `propiedad` correspondiente. Esto también activa los métodos `set` personalizados definidos para las variables exportadas, como `element`, `value`, `hide_card` y `disable_card`, lo que garantiza que las actualizaciones visuales se realicen automáticamente.
4.  **Actualización visual:** Finalmente, llama a `update_sprite()` después de asignar todas las propiedades para asegurar que la representación visual de la carta refleje todos los cambios.

```gdscript
func set_properties(values: Dictionary) -> void:
	for property in values:
		var new_value = values[property]

		if not property in self:
			push_error("Propiedad no encontrada: %s" % property)
			continue

		set(property, new_value)

	update_sprite()
```

### `update_sprite()`
Este método es responsable de actualizar la apariencia visual de la carta, incluyendo su color y la textura que muestra, basándose en su estado actual.

1.  **Verificación de `cards_list`:** Retorna tempranamente si la propiedad `cards_list` no está asignada. Esta variable `@export` (de tipo `CardsList`) es crucial porque contiene todas las texturas de las cartas y es el punto de acceso para obtener la imagen correcta.
2.  **Modulación de color:** Ajusta el color (`modulate`) de la carta. Si `disable_card` es `true`, la carta se oscurece a `Color.DIM_GRAY` para indicar que está inactiva. De lo contrario, se mantiene `Color.WHITE`.
3.  **Manejo de carta oculta:** Si `hide_card` es `true`, la textura `texture_normal` se establece en `cards_list.placeholder`. Esto oculta el diseño real de la carta y muestra una textura genérica (por ejemplo, el reverso de la carta).
4.  **Muestra de carta normal:** Si la carta no está oculta, `texture_normal` se establece llamando a `cards_list.get_card(element, value)`. Este método de `CardsList` es el encargado de obtener la textura específica para el `element` y `value` actuales de la carta.

```gdscript
func update_sprite() -> void:
	if not cards_list: return

	# Oscurece la carta cuando está desactivada
	modulate = Color.DIM_GRAY if disable_card else Color.WHITE

	if hide_card:
		texture_normal = cards_list.placeholder
		return

	texture_normal = cards_list.get_card(element, value)
```

### `hover_card(hover: bool)`
Este método gestiona la animación y los cambios visuales cuando el cursor del ratón entra o sale del área de la carta. Utiliza un `Tween` en paralelo para suavizar las transiciones.

1.  **Comprobación de deshabilitación:** Si `disable_card` es `true`, el método retorna inmediatamente, evitando cualquier efecto de `hover` en cartas deshabilitadas.
2.  **Creación del `Tween`:** Se crea un nuevo `Tween` configurado para ejecutar animaciones en paralelo (`set_parallel()`) y con una transición de `TRANS_SINE` para un movimiento suave.
3.  **Animación de `hover` (entrada):** Si `hover` es `true`:
    *   La `modulate` de la carta cambia a `Color.GRAY`, dándole un aspecto ligeramente sombreado.
    *   El `size` de la carta se incrementa verticalmente, haciéndola más grande.
    *   Si la carta no está oculta (`hide_card` es `false`), su `position` se ajusta ligeramente hacia arriba para dar la impresión de que "sale" del resto de las cartas.
4.  **Animación de `unhover` (salida):** Si `hover` es `false`:
    *   La `modulate` vuelve a `Color.WHITE`.
    *   El `size` de la carta retorna a su `_start_size` original.
    *   Si la carta no está oculta, su `position` retorna a `_start_pos`.
Todas estas transiciones utilizan `HOVER_TIME` para controlar la duración.

```gdscript
func hover_card(hover: bool) -> void:
	if disable_card: return

	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)

	# Cambia coloración, posición y tamaño de la carta
	if hover:
		tween.tween_property(self , "modulate", Color.GRAY, HOVER_TIME)
		tween.tween_property(self , "size", Vector2(_start_size.x, _start_size.y * 1.7), HOVER_TIME)

		if hide_card: return
		tween.tween_property(self , "position", _start_pos + Vector2(0, -size.y / 2) * scale, HOVER_TIME)
	else:
		tween.tween_property(self , "modulate", Color.WHITE, HOVER_TIME)
		tween.tween_property(self , "size", _start_size, HOVER_TIME)

		if hide_card: return
		tween.tween_property(self , "position", _start_pos, HOVER_TIME)
```

### `rotate_card()`
Este método maneja la animación de "rotación" o "volteo" de la carta, que se activa cuando la propiedad `hide_card` cambia. Esta animación simula que la carta se da la vuelta para mostrar su anverso o reverso.

1.  **Comprobación de inicialización:** Retorna si `_start_scale` no está inicializado, lo que indica que `_ready()` aún no se ha ejecutado.
2.  **Creación del `Tween`:** Se crea un `Tween` configurado con una transición `TRANS_SINE`. Este `Tween` es secuencial (no paralelo), lo que permite ejecutar las animaciones una tras otra.
3.  **Primera fase de la rotación:**
    *   La carta se escala a `Vector2(0, scale.y)` sobre el eje X. Esto hace que la carta parezca "adelgazar" y desaparecer momentáneamente, simulando el punto medio de una rotación 3D. La duración es `ROTATION_TIME`.
4.  **Cambio de sprite intermedio:**
    *   Una vez que la carta ha "desaparecido" (su escala X es 0), se llama a `tween.tween_callback(update_sprite)`. Esto es crucial porque en este momento es cuando la textura real de la carta se cambia (de anverso a reverso o viceversa) sin que el jugador lo perciba directamente.
5.  **Segunda fase de la rotación:**
    *   La carta se escala de nuevo a su `current_scale` original (que es `_start_scale` si no hay otros cambios). Esto hace que la carta "reaparezca" con la nueva textura, completando el efecto de volteo. La duración también es `ROTATION_TIME`.

```gdscript
func rotate_card() -> void:
	if not _start_scale: return

	# Este tween no debe ser paralelo
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	var current_scale = scale

	tween.tween_property(self , "scale", Vector2(0, scale.y), ROTATION_TIME)
	tween.tween_callback(update_sprite)
	tween.tween_property(self , "scale", current_scale, ROTATION_TIME)
```

## Funciones asociadas a señales

#### `_on_pressed()`
Esta función se conecta a la señal `pressed` del nodo `TextureButton`.
*   **Señal:** `TextureButton.pressed`
*   **Descripción:** Se activa cuando el usuario hace clic o presiona la carta.
*   **Funcionalidad:** Antes de realizar cualquier acción, verifica si la carta está deshabilitada (`disable_card`) o oculta (`hide_card`). Si alguna de estas condiciones es verdadera, la función retorna inmediatamente, impidiendo que la carta sea "presionada" funcionalmente. Si la carta es interactiva, imprime un mensaje de depuración en la consola indicando qué carta (`element` y `value`) ha sido presionada.

```gdscript
func _on_pressed() -> void:
	if disable_card or hide_card: return

	print_debug("Carta %s-%s presionada" % [element, value])
```

#### `_on_mouse_entered()`
Esta función se conecta a la señal `mouse_entered` del nodo `TextureButton`.
*   **Señal:** `Control.mouse_entered`
*   **Descripción:** Se activa cuando el puntero del ratón entra en el área de la carta.
*   **Funcionalidad:** Llama al método `hover_card(true)` para iniciar el efecto visual de `hover` (agrandar la carta, cambiar su color y desplazarla si no está oculta).

```gdscript
func _on_mouse_entered() -> void:
	hover_card(true)
```

#### `_on_mouse_exited()`
Esta función se conecta a la señal `mouse_exited` del nodo `TextureButton`.
*   **Señal:** `Control.mouse_exited`
*   **Descripción:** Se activa cuando el puntero del ratón sale del área de la carta.
*   **Funcionalidad:** Llama al método `hover_card(false)` para revertir el efecto visual de `hover`, devolviendo la carta a su estado original (tamaño, color y posición).

```gdscript
func _on_mouse_exited() -> void:
	hover_card(false)
```