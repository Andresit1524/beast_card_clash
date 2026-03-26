# `Card`
El script `Card` es el componente fundamental para representar y gestionar cada carta individual en el juego `Beast Card Clash`. Extiende de `TextureButton`, lo que le permite ser un nodo interactivo capaz de mostrar una textura y responder a eventos de mouse y pulsaciones.

Este script es responsable de:
*   **Visualización de la carta:** Mostrar la imagen correcta de la carta basándose en su elemento, valor y estado (oculta, deshabilitada).
*   **Gestión de estados:** Manejar visualmente si la carta está oculta (`hide_card`), deshabilitada (`disable_card`) o en estado normal.
*   **Interactividad:** Responder a eventos de mouse como `mouse_entered`, `mouse_exited` y `pressed` para proporcionar retroalimentación visual y emitir señales.
*   **Animaciones:** Implementar animaciones de "hover" (resaltado al pasar el mouse), volteo de carta y un sutil efecto de ondulación para dar vida a las cartas en pantalla.
*   **Comunicación:** Emitir la señal `card_selected` cuando una carta es presionada, permitiendo que otros sistemas del juego reaccionen a la elección del jugador.

La clase `Card` se apoya en un recurso `CardsList` para acceder a las texturas de las cartas y utiliza constantes para controlar la velocidad y la intensidad de sus animaciones, facilitando el ajuste fino de la experiencia visual del jugador.

# Métodos

## Métodos de Godot

### `_ready()`
Este método es llamado una vez cuando el nodo y todos sus hijos están listos. Su función principal es inicializar el pivote de la carta y asegurar que la textura inicial sea la correcta.

```gdscript
func _ready() -> void:
	# Centra el pivote
	pivot_offset = size / 2

	_update_sprite()
```

*   `pivot_offset = size / 2`: Centra el punto de pivote del nodo `TextureButton`. Esto es crucial para que las animaciones de escalado y rotación (como la de `_flip_card`) se realicen desde el centro de la carta, en lugar de una esquina.
*   `_update_sprite()`: Llama al método encargado de actualizar la textura de la carta, asegurando que muestre la imagen correcta desde el inicio, según sus propiedades `element`, `value`, `hide_card` y `disable_card`.

### `_physics_process(delta: float)`
Este método se ejecuta cada frame de física (por defecto, 60 veces por segundo, pero configurable). Es utilizado en este script para actualizar la posición de la carta y generar un efecto de ondulación constante.

```gdscript
func _physics_process(delta: float) -> void:
	# Actualiza el tiempo y posición de la carta
	elapsed_time += delta
	position = _start_position + _get_ondulation_offset()
```

*   `elapsed_time += delta`: Actualiza una variable de tiempo (`elapsed_time`) que se utiliza como fase para la función seno que genera la ondulación. Esto asegura que el efecto sea continuo y suave.
*   `position = _start_position + _get_ondulation_offset()`: Modifica la posición vertical de la carta sumando un desplazamiento calculado por `_get_ondulation_offset()` a su posición inicial (`_start_position`). Este efecto se pausa temporalmente cuando la carta es "hovered" (se pasa el mouse por encima) para evitar movimientos bruscos durante las animaciones de hover.

## Otros métodos

### `set_properties(values: Dictionary)`
Este método permite establecer múltiples propiedades de la carta de forma programática utilizando un diccionario. Es útil para inicializar o modificar el estado de una carta de manera concisa.

```gdscript
func set_properties(values: Dictionary) -> void:
	for property in values:
		var new_value = values[property]

		if not property in self:
			push_error("[Card] Propiedad no encontrada: %s" % property)
			continue

		set(property, new_value)

	_update_sprite()
```

*   Itera sobre el diccionario `values`, donde cada clave es el nombre de una propiedad de la carta (como `element`, `value`, `hide_card`, `disable_card`) y su valor es el nuevo dato a asignar.
*   Realiza una verificación (`if not property in self`) para asegurar que la propiedad existe en el script `Card`. Si no existe, se imprime un error en la consola, lo que ayuda a los desarrolladores a identificar posibles errores de escritura o propiedades no válidas.
*   `set(property, new_value)`: Utiliza el método `set()` de `Object` para asignar el nuevo valor a la propiedad especificada. Esto es importante porque permite que los `setter` personalizados de las propiedades `@export` (como `element`, `value`, `hide_card`, `disable_card`) se ejecuten, actualizando la visualización de la carta según sea necesario.
*   `_update_sprite()`: Después de actualizar todas las propiedades, se llama a este método para asegurar que la carta refleje los cambios visualmente.

### `_update_sprite()`
Este método es responsable de cambiar la textura visual de la carta, así como su modulación de color, basándose en el estado actual de sus propiedades.

```gdscript
func _update_sprite() -> void:
	if not cards_list: return

	# Oscurece la carta cuando está desactivada
	modulate = Color.DIM_GRAY if disable_card else Color.WHITE

	if hide_card:
		texture_normal = cards_list.placeholder
		return

	texture_normal = cards_list.get_card(element, value)
```

*   `if not cards_list: return`: Verifica que la `cards_list` (un recurso `CardsList` que contiene las texturas de las cartas) esté asignada. Si no lo está, la función termina para evitar errores al intentar acceder a texturas inexistentes.
*   `modulate = Color.DIM_GRAY if disable_card else Color.WHITE`: Ajusta la `modulate` de la carta. Si `disable_card` es `true`, la carta se muestra atenuada con un color gris oscuro; de lo contrario, se muestra con su color normal (`Color.WHITE`).
*   `if hide_card: texture_normal = cards_list.placeholder; return`: Si `hide_card` es `true`, la textura de la carta se establece al `placeholder` (la parte trasera de la carta) definido en `cards_list`, y la función termina.
*   `texture_normal = cards_list.get_card(element, value)`: Si la carta no está oculta, obtiene la textura correspondiente al `element` y `value` actuales de la carta a través del método `get_card` de `cards_list` y la asigna a `texture_normal`.

### `_hover_card(hover: bool)`
Gestiona la animación y los cambios visuales cuando el mouse entra o sale de la superficie de la carta.

```gdscript
func _hover_card(hover: bool) -> void:
	if disable_card: return

	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)

	# Cambia coloración, posición y tamaño de la carta
	# Se desactiva o activa physics_process para evitar que la carta salte a su sitio original
	if hover:
		tween.tween_property(self, "modulate", Color.GRAY, HOVER_TIME)
		tween.tween_property(self, "size", Vector2(_start_size.x, _start_size.y * 1.5), HOVER_TIME)

		if hide_card: return
		set_physics_process(false)
		var hover_offset := Vector2(0, -size.y / 2) * scale
		tween.tween_property(self, "position", _start_position + hover_offset, HOVER_TIME)
	else:
		tween.tween_property(self, "modulate", Color.WHITE, HOVER_TIME)
		tween.tween_property(self, "size", _start_size, HOVER_TIME)

		if hide_card: return
		tween.tween_property(self, "position", _start_position, HOVER_TIME)
		tween.tween_callback(func(): set_physics_process(true))
```

*   `if disable_card: return`: Si la carta está deshabilitada, no se aplica ningún efecto de hover.
*   `var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)`: Crea un `Tween` para las animaciones, configurándolo para que las propiedades se animen en paralelo (`set_parallel()`) y con una curva de interpolación `TRANS_SINE` para un movimiento suave.
*   **Si `hover` es `true` (el mouse entra):**
    *   `tween.tween_property(self, "modulate", Color.GRAY, HOVER_TIME)`: Cambia el color de la carta a un gris más oscuro.
    *   `tween.tween_property(self, "size", Vector2(_start_size.x, _start_size.y * 1.5), HOVER_TIME)`: Aumenta la altura de la carta para dar un efecto de "agrandamiento".
    *   `if hide_card: return`: Si la carta está oculta, no se aplica el desplazamiento vertical, ya que no se espera que las cartas ocultas se muevan al hacer hover.
    *   `set_physics_process(false)`: Desactiva `_physics_process` temporalmente para que la animación de hover no se vea interrumpida por el efecto de ondulación.
    *   `var hover_offset := Vector2(0, -size.y / 2) * scale`: Calcula un desplazamiento vertical hacia arriba para que la carta parezca "flotar".
    *   `tween.tween_property(self, "position", _start_position + hover_offset, HOVER_TIME)`: Anima la posición de la carta para que se mueva hacia arriba.
*   **Si `hover` es `false` (el mouse sale):**
    *   `tween.tween_property(self, "modulate", Color.WHITE, HOVER_TIME)`: Restaura el color original de la carta.
    *   `tween.tween_property(self, "size", _start_size, HOVER_TIME)`: Restaura el tamaño original de la carta.
    *   `if hide_card: return`: Si la carta está oculta, no se restaura el desplazamiento vertical.
    *   `tween.tween_property(self, "position", _start_position, HOVER_TIME)`: Anima la posición de la carta para que vuelva a su lugar original.
    *   `tween.tween_callback(func(): set_physics_process(true))`: Después de que la animación de retorno ha terminado, reactiva `_physics_process` para que el efecto de ondulación se reanude.

### `_flip_card()`
Este método anima el volteo de la carta, cambiando su escala en el eje X para simular un giro y actualizando su sprite en el punto medio de la animación para mostrar el anverso o reverso.

```gdscript
func _flip_card() -> void:
	if not _start_scale: return

	# Este tween no debe ser paralelo
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	var current_scale = scale

	tween.tween_property(self, "scale", Vector2(0, scale.y), ROTATION_TIME)
	tween.tween_callback(_update_sprite)
	tween.tween_property(self, "scale", current_scale, ROTATION_TIME)
```

*   `if not _start_scale: return`: Evita ejecutar la animación si `_start_scale` no ha sido inicializado, lo que podría ocurrir si la función es llamada antes de `_ready()`.
*   `var tween := create_tween().set_trans(Tween.TRANS_SINE)`: Crea un `Tween` para la animación. Es importante que este `Tween` *no* sea paralelo, ya que los pasos deben ejecutarse secuencialmente para simular el volteo.
*   `var current_scale = scale`: Guarda la escala actual de la carta para restaurarla al final de la animación.
*   `tween.tween_property(self, "scale", Vector2(0, scale.y), ROTATION_TIME)`: Anima la escala horizontal (`x`) de la carta a `0`, haciéndola desaparecer momentáneamente.
*   `tween.tween_callback(_update_sprite)`: En el punto medio de la animación (cuando la escala `x` es `0`), llama a `_update_sprite()` para cambiar la textura de la carta (por ejemplo, de anverso a reverso o viceversa).
*   `tween.tween_property(self, "scale", current_scale, ROTATION_TIME)`: Anima la escala horizontal de la carta de vuelta a su valor original, completando el efecto de volteo y revelando la nueva textura.

### `_get_ondulation_offset() -> Vector2`
Calcula el desplazamiento vertical para el efecto de ondulación de la carta.

```gdscript
func _get_ondulation_offset() -> Vector2:
	return Vector2(0, sin(elapsed_time * ONDULAION_SPEED)) * ONDULAION_STRENGHT
```

*   Utiliza la función seno (`sin()`) con `elapsed_time` (tiempo transcurrido desde que la carta está en escena) y `ONDULAION_SPEED` (velocidad de la ondulación) para generar un valor que varía suavemente entre `-1` y `1`.
*   Este valor se multiplica por `ONDULAION_STRENGHT` para controlar la magnitud del desplazamiento vertical.
*   El resultado es un `Vector2` que solo afecta el componente `y` de la posición de la carta, creando un movimiento de arriba y abajo suave y rítmico.

## Funciones asociadas a señales

#### `_on_pressed()`
Este método se ejecuta cuando el nodo `TextureButton` (la carta) es presionado.

```gdscript
func _on_pressed() -> void:
	if disable_card or hide_card: return

	print(
		"[Card] Carta %s-%s presionada"
		% [Utilities.get_enum_name(element, GameConstants.Elements), value]
	)
	card_selected.emit(self)
```

*   **Señal a la que apunta:** `pressed` (una señal inherente de `BaseButton`).
*   **Funcionamiento:**
    *   `if disable_card or hide_card: return`: Verifica si la carta está deshabilitada o escondida. Si es así, la función termina y la carta no responde a la pulsación. Esto asegura que el jugador no pueda interactuar con cartas no válidas o no visibles.
    *   `print(...)`: Imprime un mensaje en la consola de Godot indicando qué carta ha sido presionada, útil para depuración. Se utiliza la utilidad `Utilities.get_enum_name` para mostrar el nombre del elemento de forma legible, asumiendo la existencia de una clase `Utilities` que contiene este método y `GameConstants.Elements` como un enumerado para los elementos del juego.
    *   `card_selected.emit(self)`: Emite la señal personalizada `card_selected`, pasando una referencia a la propia instancia de la `Card` como argumento. Esto permite que otros scripts o sistemas (como un gestor de juego o de mano de jugador) puedan detectar cuándo una carta ha sido elegida por el jugador y reaccionar en consecuencia.

#### `_on_mouse_entered()`
Este método se ejecuta cuando el puntero del mouse entra en el área de colisión del nodo `TextureButton`.

```gdscript
func _on_mouse_entered() -> void:
	_hover_card(true)
```

*   **Señal a la que apunta:** `mouse_entered` (una señal inherente de `Control`).
*   **Funcionamiento:** Llama al método `_hover_card(true)` para activar el efecto visual de "hover", que incluye cambios de color, tamaño y posición para resaltar la carta.

#### `_on_mouse_exited()`
Este método se ejecuta cuando el puntero del mouse sale del área de colisión del nodo `TextureButton`.

```gdscript
func _on_mouse_exited() -> void:
	_hover_card(false)
```

*   **Señal a la que apunta:** `mouse_exited` (una señal inherente de `Control`).
*   **Funcionamiento:** Llama al método `_hover_card(false)` para desactivar el efecto visual de "hover", restaurando la carta a su estado visual original.